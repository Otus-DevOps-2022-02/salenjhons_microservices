Homework #18 (kubernetes-2)

Запуск кластера и приложения.

Устновлен minikube на локальный хост.
minikube start --kubernetes-version 1.19.7

Созданы деплойменты для компонентов:
ui (ui-deployment)
post (post-deployment)
comment (commment-deployment)
mongodb (mongodb-deployment)

Запуск деплойментов:
kubectl apply -f ./kubernetes/reddit

Проброской порта проверяем доступность ui компонента:

kubectl get pods --selector component=ui
kubectl port-forward <pod-name> 8080:9292

Для связи компонентов между собой и с внешним миром используется объект Service:
post-service.yml
comment-service.yml
mongodb-service.yml
ui-service.yml

Для доступа к одному ресурсу под разными созданые манифесты:
post-mongodb-service.yml
comment-mongodb-service.yml


Для проверки логов на post поде:
kubectl logs <pod-name>


Для доступа к ui-сервису из вне добавляем тип NodePort на каждой ноде кластера открывает порт из
диапазона 30000-32767 и переправляет трафик с этого порта на тот,
который указан в targetPort Pod :

spec:
 type: NodePort
 ports:
 - nodePort: 32092
 port: 9292
 protocol: TCP
 targetPort: 9292
 selector:

Выдает web-страницы с сервисами, которые были помечены типом NodePort
minikube service ui

Создан свой Namespace dev:
dev-namespace.yml

Запуск приложения в namespace dev:
kubectl apply -n dev -f .

Написан манифест ~kubernetes/terraform/k8s/main.tf для разворачивания кубер кластера в яндекс облаке.



Homework #17 (kubernetes-1)

Установка Docker на ubuntu 18.04:

sudo apt update && sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt update && sudo apt install -y docker-ce=5:19.03.15~3-0~ubuntu-bionic docker-ce-cli=5:19.03.15~3-0~ubuntu-bionic

Установка k8s на ubuntu 18.04:

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update && sudo apt install -y kubelet=1.19.16-00 kubeadm=1.19.16-00 kubectl=1.19.16-00
sudo apt-mark hold kubelet kubeadm kubectl
Иннициализация мастер-ноды на первом хосте:

sudo kubeadm init --apiserver-cert-extra-sans=<external-master-ip> \
  --apiserver-advertise-address=0.0.0.0 \
  --control-plane-endpoint=<external-master-ip> \
  --pod-network-cidr=10.244.0.0/16

Добавление в кластер воркер-ноды на втором хосте:

kubeadm join <external-master-ip>:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<cert-hash>
Для управления кластером через kubectl нужно скопировать config с мастер-ноды На самом хосте:

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
на удаленном хосте:

scp ubuntu@<external-master-ip>:~/.kube/config ~/.kube/config
Инофрмация о нодах можно получить командой:

kubectl get nodes

Установка CNI плагина calico
Для установки CNI плагина calico нужно применить манифест в k8s. Манифест по ссылке из офф документации при применении вызывает ошибку:

unable to recognize "calico.yaml": no matches for kind "PodDisruptionBudget" in version "policy/v1"
Скачаем альтернативную версию манифеста:

curl https://docs.projectcalico.org/v3.20/manifests/calico.yaml -O
Раскоменнтируем CALICO_IPV4POOL_CIDR и определим 10.244.0.0/16. Применим:

kubectl apply -f calico.yaml
Все ноды переходят в READY статус.

Применение манифестов приложения reddit


cd kubernetes/reddit
kubectl apply -f mongo-deployment.yml
kubectl apply -f post-deployment.yml
kubectl apply -f comment-deployment.yml
kubectl apply -f ui-deployment.yml
kubectl get pods -w

Homework #16 (logging-1)

Для сборов логов из Docker-контейнеров используется стек Elasticsearch-Fluentd-Kibana (EFK) Стек запускается через docker-compose docker/docker-compose-logging.yml. Конетейнер с конфигурацией Fluentd собирается из Dockerfile в logging/fluentd. Сборка конейнеров приложений:

export USER_NAME='логин на Docker Hub'
cd ./src/ui && bash docker_build.sh && docker push $USER_NAME/ui
cd ../post-py && bash docker_build.sh && docker push $USER_NAME/post
cd ../comment && bash docker_build.sh && docker push $USER_NAME/comment
Запуск EFK и приложения (выставить переменные среды в .env):

cd logging/fluentd/
docker build -t $USER_NAME/fluentd .
cd ../../docker/
docker-compose -f docker-compose-logging.yml up -d
docker-compose -f docker-compose.yml up -d
В конфигурацию Fluentd добавлены фильтры для структурированных логов приложения post и фильтры с grok для неструктурированных логов приложения ui. Использовался обновленный сиснтаксис плагина fluent-plugin-grok-parser В docker-compose приложения добавлены environment переменные.

Сбор трейсов с Zipkin
Для сбора трейсов добавляем контейнер zipkin в docker/docker-compose-logging.yml, отправка трейсов в приложениях включается env-переменной ZIPKIN_ENABLED. Добавляем сети приложений в docker/docker-compose-logging.yml для доступа приложений к конетенеру.

Фильтр неструктурированных логов приложения ui:

<filter service.ui>
  @type parser
  key_name message
  format grok
  <parse>
    @type grok
    <grok>
      pattern service=%{WORD:service} \| event=%{WORD:event} \| path=%{URIPATHPARAM:request} \| request_id=%{GREEDYDATA:request_id} \| remote_addr=%{IP:client} \| method=.%{WORD:method} \| response_status=%{NUMBER:response_status}
    </grok>
  </parse>
  reserve_data true
</filter>

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
