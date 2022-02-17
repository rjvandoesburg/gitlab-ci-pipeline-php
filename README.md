# Build and test PHP applications with Gitlab CI (or any other CI platform)

> Docker images with everything you'll need to build and test PHP applications.

![Logo](https://raw.githubusercontent.com/rjvandoesburg/gitlab-ci-pipeline-php/master/gitlab-ci-pipeline-php.png)

---
![GitHub last commit](https://img.shields.io/github/last-commit/rjvandoesburg/gitlab-ci-pipeline-php.svg?style=for-the-badge&logo=git) [![Docker Pulls](https://img.shields.io/docker/pulls/rjvandoesburg/gitlab-ci-pipeline-php.svg?style=for-the-badge&logo=docker)](https://hub.docker.com/r/rjvandoesburg/gitlab-ci-pipeline-php/) [![building status](https://gitlab.com/rjvandoesburg/gitlab-ci-pipeline-php/badges/master/pipeline.svg)](https://gitlab.com/rjvandoesburg/gitlab-ci-pipeline-php/commits/master)

---

## Based on [Official PHP images](https://hub.docker.com/_/php/)

> PHP 8.0 available!

- ```8.0```, ```8```, ```latest``` [(8.0/Dockerfile)](https://github.com/rjvandoesburg/gitlab-ci-pipeline-php/blob/master/php/8.0/Dockerfile) - [![](https://images.microbadger.com/badges/image/rjvandoesburg/gitlab-ci-pipeline-php:8.0.svg)](https://microbadger.com/images/rjvandoesburg/gitlab-ci-pipeline-php:8.0 "Get your own image badge on microbadger.com")

- ```8.0-fpm```, ```fpm``` [(8.0/fpm/Dockerfile)](https://github.com/rjvandoesburg/gitlab-ci-pipeline-php/blob/master/php/8.0/fpm/Dockerfile) - [![](https://images.microbadger.com/badges/image/rjvandoesburg/gitlab-ci-pipeline-php:8.0-fpm.svg)](https://microbadger.com/images/rjvandoesburg/gitlab-ci-pipeline-php:8.0-fpm "Get your own image badge on microbadger.com")


All versions come with [Node 14](https://nodejs.org/en/), [Composer](https://getcomposer.org/) and [Yarn](https://yarnpkg.com)

---

## Laravel projects

All images come with PHP (with all laravel required extensions), Composer (with [hirak/prestissimo](https://github.com/hirak/prestissimo) to speed up installs), Node and [Yarn](https://yarnpkg.com).

Everything you need to test Laravel projects :D

## Gitlab pipeline examples

### Laravel test examples

#### Simple ```.gitlab-ci.yml``` using mysql service

```yaml
# Variables
variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_USER: homestead
  MYSQL_PASSWORD: secret
  MYSQL_DATABASE: homestead
  DB_HOST: mysql

test:
  stage: test
  services:
    - mysql:5.7
  image: rjvandoesburg/gitlab-ci-pipeline-php:8.0
  script:
    - yarn install --pure-lockfile
    - composer install --prefer-dist --no-ansi --no-interaction --no-progress
    - cp .env.example .env
    - php artisan key:generate
    - php artisan migrate:refresh --seed
    - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
```

#### Advanced ```.gitlab-ci.yml``` using mysql service, stages and cache

```yaml
stages:
  - test
  - deploy

# Variables
variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_USER: homestead
  MYSQL_PASSWORD: secret
  MYSQL_DATABASE: homestead
  DB_HOST: mysql

# Speed up builds
cache:
  key: $CI_BUILD_REF_NAME # changed to $CI_COMMIT_REF_NAME in Gitlab 9.x
  paths:
    - vendor
    - node_modules
    - public
    - .yarn


test:
  stage: test
  services:
    - mysql:5.7
  image: rjvandoesburg/gitlab-ci-pipeline-php:8.0
  script:
    - yarn config set cache-folder .yarn
    - yarn install --pure-lockfile
    - composer install --prefer-dist --no-ansi --no-interaction --no-progress
    - cp .env.example .env
    - php artisan key:generate
    - php artisan migrate:refresh --seed
    - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
  artifacts:
    paths:
      - ./storage/logs # for debugging
    expire_in: 7 days
    when: always

deploy:
  stage: deploy
  image: rjvandoesburg/gitlab-ci-pipeline-php:8.0-alpine
  script:
    - echo "Deploy all the things!"
  only:
    - master
  when: on_success
```
