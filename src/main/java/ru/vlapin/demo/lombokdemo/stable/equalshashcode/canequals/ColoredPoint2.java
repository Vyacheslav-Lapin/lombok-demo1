package ru.vlapin.demo.lombokdemo.stable.equalshashcode.canequals;

import java.awt.Color;

public class ColoredPoint1 extends Point {

  Color color;

  ColoredPoint1(int x, int y, Color color) {
    super(x, y);
    this.color = color;
  }

  @Override public boolean equals(Object o) {
    return this == o
               || super.equals(o)
                      && o instanceof ColoredPoint1 coloredPoint
                      && (color != null ? color.equals(coloredPoint.color)
                              : coloredPoint.color == null);

  }

  @Override public int hashCode() {
    int result = super.hashCode();
    result = 31 * result + (color != null ? color.hashCode() : 0);
    return result;
  }
}
