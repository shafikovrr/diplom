
#  Дипломная работа по профессии «Системный администратор»

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю) 

---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. 

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

![web-hosts-group.png](img/web-hosts-group.png)

Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

![web-hosts-backend-group.png](img/web-hosts-backend-group.png)

Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

![web-hosts-http-router.png](img/web-hosts-http-router.png)

Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

![web-hosts-balancer.png](img/web-hosts-balancer.png)

![web-hosts-balancer-2.png](img/web-hosts-balancer-2.png)

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

![curl-alb.png](img/curl-alb.png)

Порядок запуска плейбуков и вывод результатов их работы

![1-ansible-nginx.png](img/1-ansible-nginx.png)

![2-ansible-elasticsearch.png](img/2-ansible-elasticsearch.png)

![3-ansible-kibana.png](img/3-ansible-kibana.png)

![4-ansible-postgresql.png](img/4-ansible-postgresql.png)

![5-ansible-zabbix.png](img/5-ansible-zabbix.png)

![6-ansible-filebeat.png](img/6-ansible-filebeat.png)

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

![zabbix-add-hosts.png](img/zabbix-add-hosts.png)

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

![zabbix-dashboard.png](img/zabbix-dashboard.png)

![zabbix-tresholds.png](img/zabbix-tresholds.png)

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

![elasticsearch-status.png](img/elasticsearch-status.png)

![web1-filebeat-status.png](img/web1-filebeat-status.png)

![web2-filebeat-status.png](img/web2-filebeat-status.png)

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

![kibana-access.log.png](img/kibana-access.log.png)

### Сеть
Развернут один VPC (файл network.tf). Сервера web, Elasticsearch поместил в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть (файл bastion.tf).

Настроил [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам (файл network.tf).

Настроил ВМ с публичным адресом, в которой будет открыт только один порт — ssh [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion). Ansible  и terraform установлены на локальной ВМ.

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

![snapshot.png](img/snapshot.png)

bastion.tf - настройка ВМ и snapshot
yandex_compute_disk.tf - диски ВМ
network.tf - настройка сети, подсети, sg, балансировщика , роутера
ansible_hosts.tf - создает файл hosts для ansible
inventory.tf - генерирует файл конфиг для ssh (для доступа к бастиону и остальным ВМ)
ansible/queue - порядок запукса плейбуков

Спасибо за проверку.