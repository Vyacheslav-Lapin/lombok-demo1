package ru.vlapin.demo.lombokdemo.delegate.cp;

public class ConnectionPoolException extends RuntimeException {

  public ConnectionPoolException(String message, Exception e) {
    super(message, e);
  }

  public ConnectionPoolException(String message) {
    super(message);
  }

  public ConnectionPoolException(Throwable cause) {
    super(cause);
  }
}
