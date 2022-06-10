Homework #15 (monitoring-1)

Созданы Dockerfile и конфигурация Prometheus. Команда для сборки всех образов приложений:

export USER_NAME=username
for i in ui post-py comment; do cd src/$i; bash docker_build.sh; cd -; done
Отредактирован файл docker-compose.yml для запуска контейненеров с Prometheus. Убраны команды build, Добавлены network aliases. Контейнеры загружены в DockerHub.

22.2 Задания со *
Добален мониторинг БД с помощью percona/mongodb_exporter. Добален мониторинг Blackbox. Создан Makefile для сборки и отправки образов.


Homework #14 (gitlab-ci-1)

Основное ДЗ

Подняли машину с докером в GCP
Установили туда Gitlab CI, gitlab-runner
Создали группу проектов, проект
Создали пайплайн и зарегистрировали его
Добавили исходный код приложения в репозиторий
Добавили тест для приложения
Описали несколько окружений
stage и prod окружения запускаются только тогда, когда проставлен тэг в гите
Добавили динамические окружения
Задание со*

Как делать билд контейнеров докер в GitLab описано в документации.
Для автоматизации установки gitlab-runner можно использовать готовые ansible роли, как например эта


Homework #13 (docker-4)

В данном ДЗ мы научились работать с сетью Docker/
Создали сети: loop, host, birdge.
Научились управлять соединениямиЮ не заходя в контейнер.
Посмотрели на правила iptables, создаваемые для Docker контейнеров.
Научились собирать docker-compose

Для установки имени необходимо вводить --porject-name= или -p docker-compose --project-name=<name of project" up -d.
В противном случае по умолчанию название проекта присваивается согласно названию директории, откуда был произведен запуск сборки.

Homework #12 (docker-3)

Использованы общие техники оптимазации написания докерфайлов.
Рассмотрена работы нескольких контейнеров в бридж сети.

Homework #11 (docker-2)

В данном дз мы научились рабоать с Docker контейнерами Создавать их удалять и тд Научились создавать образы Развернули тестовое приложение В задании со * были созданы ВМ в яндекс облаке с помощью terraform Настроены с помощью ansible ВМ и запущен докер контейнер с приложением из образа на Docker Hub который мы создали Для запуска сборки образа в облаке с помощью packer используйте команду packer build -var-file=packer/variables.json packer/docker.json из директории docker-monolith
