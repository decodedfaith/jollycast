import 'package:dio/dio.dart';

enum ErrorType {
  network,
  authentication,
  server,
  validation,
  timeout,
  notFound,
  noInternet,
  poorConnection,
  unknown,
}

class AppError {
  final ErrorType type;
  final String message;
  final String? technicalDetails;
  final bool canRetry;

  AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.canRetry = false,
  });
}

class ErrorHandler {
  static AppError handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is Exception) {
      return _handleException(error);
    } else {
      return AppError(
        type: ErrorType.unknown,
        message: 'An unexpected error occurred. Please try again.',
        technicalDetails: error.toString(),
        canRetry: true,
      );
    }
  }

  static AppError _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppError(
          type: ErrorType.poorConnection,
          message:
              'Connection is too slow. Please check your internet speed and try again.',
          technicalDetails: error.message,
          canRetry: true,
        );

      case DioExceptionType.sendTimeout:
        return AppError(
          type: ErrorType.poorConnection,
          message:
              'Upload is taking too long. Your internet connection may be slow.',
          technicalDetails: error.message,
          canRetry: true,
        );

      case DioExceptionType.receiveTimeout:
        return AppError(
          type: ErrorType.timeout,
          message: 'Server is not responding. Please try again later.',
          technicalDetails: error.message,
          canRetry: true,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.connectionError:
        // Check if it's specifically no internet
        final errorMessage = error.message?.toLowerCase() ?? '';
        final errorString = error.error?.toString().toLowerCase() ?? '';

        if (errorMessage.contains('network is unreachable') ||
            errorMessage.contains('failed host lookup') ||
            errorString.contains('socketexception') ||
            errorString.contains('network is unreachable')) {
          return AppError(
            type: ErrorType.noInternet,
            message:
                'No internet connection. Please check your WiFi or mobile data and try again.',
            technicalDetails: error.message,
            canRetry: true,
          );
        }

        return AppError(
          type: ErrorType.network,
          message:
              'Unable to connect to the server. Please check your internet connection.',
          technicalDetails: error.message,
          canRetry: true,
        );

      case DioExceptionType.cancel:
        return AppError(
          type: ErrorType.unknown,
          message: 'Request was cancelled.',
          technicalDetails: error.message,
          canRetry: false,
        );

      case DioExceptionType.badCertificate:
        return AppError(
          type: ErrorType.network,
          message:
              'Security certificate error. Please check your connection or try again later.',
          technicalDetails: error.message,
          canRetry: false,
        );

      default:
        return AppError(
          type: ErrorType.unknown,
          message: 'An unexpected error occurred. Please try again.',
          technicalDetails: error.message,
          canRetry: true,
        );
    }
  }

  static AppError _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;

    // Try to extract error message from response
    String? apiMessage;
    if (responseData is Map) {
      apiMessage =
          responseData['message'] as String? ??
          responseData['error'] as String? ??
          responseData['msg'] as String? ??
          responseData['errors']?.toString();
    } else if (responseData is String) {
      apiMessage = responseData;
    }

    switch (statusCode) {
      case 400:
        return AppError(
          type: ErrorType.validation,
          message:
              apiMessage ??
              'Invalid request. Please check your input and try again.',
          technicalDetails: error.message,
          canRetry: false,
        );

      case 401:
        // Check if it's specifically a wrong password/credentials issue
        final lowerApiMessage = apiMessage?.toLowerCase() ?? '';

        if (lowerApiMessage.contains('password') ||
            lowerApiMessage.contains('credential') ||
            lowerApiMessage.contains('invalid login') ||
            lowerApiMessage.contains('authentication failed')) {
          return AppError(
            type: ErrorType.authentication,
            message:
                'Incorrect phone number or password. Please check your credentials and try again.',
            technicalDetails: error.message,
            canRetry: false,
          );
        } else if (lowerApiMessage.contains('token') ||
            lowerApiMessage.contains('session') ||
            lowerApiMessage.contains('expired')) {
          return AppError(
            type: ErrorType.authentication,
            message: 'Your session has expired. Please log in again.',
            technicalDetails: error.message,
            canRetry: false,
          );
        }

        return AppError(
          type: ErrorType.authentication,
          message: apiMessage ?? 'Authentication failed. Please log in again.',
          technicalDetails: error.message,
          canRetry: false,
        );

      case 403:
        return AppError(
          type: ErrorType.authentication,
          message:
              apiMessage ??
              'Access denied. You don\'t have permission to access this resource.',
          technicalDetails: error.message,
          canRetry: false,
        );

      case 404:
        return AppError(
          type: ErrorType.notFound,
          message:
              apiMessage ??
              'The requested content was not found. It may have been removed or is temporarily unavailable.',
          technicalDetails: error.message,
          canRetry: false,
        );

      case 422:
        return AppError(
          type: ErrorType.validation,
          message:
              apiMessage ??
              'Please check your input. Some fields contain invalid data.',
          technicalDetails: error.message,
          canRetry: false,
        );

      case 429:
        return AppError(
          type: ErrorType.server,
          message: 'Too many requests. Please wait a moment and try again.',
          technicalDetails: error.message,
          canRetry: true,
        );

      case 500:
        return AppError(
          type: ErrorType.server,
          message:
              'Server error occurred. Our team has been notified. Please try again later.',
          technicalDetails: error.message,
          canRetry: true,
        );

      case 502:
      case 503:
        return AppError(
          type: ErrorType.server,
          message:
              'Server is temporarily unavailable. Please try again in a few moments.',
          technicalDetails: error.message,
          canRetry: true,
        );

      case 504:
        return AppError(
          type: ErrorType.timeout,
          message:
              'Server request timed out. Please check your connection and try again.',
          technicalDetails: error.message,
          canRetry: true,
        );

      default:
        return AppError(
          type: ErrorType.unknown,
          message: apiMessage ?? 'Failed to fetch data. Please try again.',
          technicalDetails: error.message,
          canRetry: true,
        );
    }
  }

  static AppError _handleException(Exception exception) {
    final message = exception.toString().toLowerCase();

    // Check for no internet
    if (message.contains('socketexception') ||
        message.contains('network is unreachable') ||
        message.contains('failed host lookup')) {
      return AppError(
        type: ErrorType.noInternet,
        message:
            'No internet connection. Please check your WiFi or mobile data and try again.',
        technicalDetails: exception.toString(),
        canRetry: true,
      );
    }

    // Check for authentication
    if (message.contains('401') ||
        message.contains('authentication') ||
        message.contains('unauthorized')) {
      if (message.contains('password') || message.contains('credential')) {
        return AppError(
          type: ErrorType.authentication,
          message:
              'Incorrect phone number or password. Please check your credentials and try again.',
          technicalDetails: exception.toString(),
          canRetry: false,
        );
      }
      return AppError(
        type: ErrorType.authentication,
        message: 'Authentication failed. Please log in again.',
        technicalDetails: exception.toString(),
        canRetry: false,
      );
    }

    // Check for timeout
    if (message.contains('timeout')) {
      return AppError(
        type: ErrorType.timeout,
        message:
            'Request timed out. Please check your connection and try again.',
        technicalDetails: exception.toString(),
        canRetry: true,
      );
    }

    // Check for format/parsing errors (code-related)
    if (message.contains('formatexception') ||
        message.contains('type') ||
        message.contains('null') ||
        message.contains('parse')) {
      return AppError(
        type: ErrorType.unknown,
        message:
            'Data format error. The app needs an update. Please contact support if this persists.',
        technicalDetails: exception.toString(),
        canRetry: false,
      );
    }

    // Default
    return AppError(
      type: ErrorType.unknown,
      message: 'An unexpected error occurred. Please try again.',
      technicalDetails: exception.toString(),
      canRetry: true,
    );
  }

  static String getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.noInternet:
        return '📵';
      case ErrorType.poorConnection:
        return '🐌';
      case ErrorType.network:
        return '📡';
      case ErrorType.authentication:
        return '🔒';
      case ErrorType.server:
        return '⚠️';
      case ErrorType.validation:
        return '✏️';
      case ErrorType.timeout:
        return '⏱️';
      case ErrorType.notFound:
        return '🔍';
      case ErrorType.unknown:
        return '❌';
    }
  }
}
