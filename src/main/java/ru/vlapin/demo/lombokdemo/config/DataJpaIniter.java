package ru.vlapin.demo.lombokdemo.config;

import java.util.stream.Stream;

import lombok.RequiredArgsConstructor;
import ru.vlapin.demo.lombokdemo.common.Loggable;
import ru.vlapin.demo.lombokdemo.dao.CatRepository;
import ru.vlapin.demo.lombokdemo.model.Cat;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataJpaIniter implements ApplicationRunner {

  CatRepository catRepository;

  @Loggable
  @Override
  public void run(ApplicationArguments __) {
    Stream.of("Мурзик, Барсик, Матроскин".split(", "))
        .map(Cat::new)
        .forEach(catRepository::save);
  }
}
