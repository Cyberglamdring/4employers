# KUBERNETES

## Table of contents

1. [Архитектура]()
2. [Терминология]()
3. [Pods]()
4. [Network]()
5. [Volume]()
6. [ReplicaSet]()
7. [Deployments]()
8. [Garbage Collector]()
9. [Диаграмма]()
10. [Список источников]()

**Кубернетес** – открытое ПО для автоматизации развёртывания, масштабирования и управления контейнеризированными приложениями. Поддерживает до 5 000 nodes и 150 000 pod.
| Info  | Description|
| --- | --- |
| **Написано на** | Go |
| **Автор-создатель** | Google |
| **Последняя версия** | 1.16.0 (18 сентября 2019) |

## Архитектура

Работа с кластером осуществляется через API с помощью утилиты kubectl или через Дашборд, который тоже взаимодействует с API.

```bash
$ kubectl cluster-info
Kubernetes master is running at https://192.168.100.51:6443
KubeDNS is running at https://192.168.100.51:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

Кластер включает в себя два типа узла:

- Мастеры (masters) – управляющий узел кластера, работает с:
  - API-сервер (kube-apiserver);
  - Планировщик (kube-scheduler);
  - Менеджер контроллеров (kube-controller-manager);
  - Хранилище (etcd).
- Ноды (nodes) – рабочие узлы, работают с:
  - kube-proxy – маршрутизация траффика;
  - kubelet – получение инструкций от управляющего узла и приведение под на данном рабочем узле в желаемое состояние;
  - Работа с плагинами. Например:
    - Flannel для организации сетевого взаимодействия или мониторинга и сбора метрик;
    - MetalLB – network load-balancer;
    - NGINX Ingress controller – балансировщик нагрузки.

```bash
$ kubectl get pods -n kube-system
NAME                             READY   STATUS    RESTARTS   AGE
coredns-5644d7b6d9-kx2hr         1/1     Running   2          73m
coredns-5644d7b6d9-x48hc         1/1     Running   2          73m
etcd-master                      1/1     Running   2          72m
kube-apiserver-master            1/1     Running   2          72m
kube-controller-manager-master   1/1     Running   2          72m
kube-flannel-ds-amd64-n87zk      1/1     Running   2          73m
kube-proxy-wwbpz                 1/1     Running   2          73m
kube-scheduler-master            1/1     Running   2          72m
```

### Терминология

|Термин|Определение|
|---|---|
|**Pods**|Минимальная сущность (юнит) для развертывания в кластере|
|**ReplicaSets** (ранее Replication Controller) |Гарантирует, что в определенный момент времени будет запущено нужно кол-во контейнеров|
|**Deployments**|Обеспечивает декларативные (declarative) обновления для Pods и ReplicaSets|
|**StatefulSets**|Используется для управления приложениями с сохранением состояния.
|**DaemonSet**|Гарантирует, что определенный под будет запущен на всех (или некоторых) нодах|
|**Jobs** (в том числе CronJob)|Cоздает один (или несколько) под и гарантирует, что после выполнения команды они будут успешно завершены (terminated)|
|**Labels and Selectors**|Пары ключ/значение, которые присваиваются объектам. С помощью селекторов пользователь может идентифицировать объект|
|**Namespaces**|Виртуальные кластеры, размещенные поверх физического|
|**Services**|Абстракция, которая определяет логический набор под и политику доступа к ним|
|**Annotations**|Добавление произвольных неидентифицирующих метаданных к объектам|
|**ConfigMaps**|Позволяет переопределить конфигурацию запускаемых под|
|**Secrets**|Используются для хранения конфиденциальной информации (пароли, токены, ssh-ключи)|

## Pod

**Pod** – это «строительный блок» кластера и состоит из одного или нескольких контейнеров, хранилища (storage), отдельного IP-адреса и опций, которые определяют, как именно контейнер(ы) должны запускаться.

В кластере Kubernetes Pod'ы используются двумя способами:

- Pod из **одного** контейнера. В этом варианте Pod можно представить как обертку вокруг одного контейнера;
- Pod из **нескольких** работающих сообща контейнеров. Контейнеры в данном случае образуют отдельную единицу (сервис) и используют общие ресурсы, например, файлы из одного хранилища (storage). При этом отдельный контейнер Pod'а может обновлять эти файлы.

Каждый Pod предназначен для запуска одного экземпляра конкретного приложения. Для горизонтального масштабирования можно запустить несколько экземпляров – это репликация. Реплицированные Pod'ы создаются и управляются как единая группа абстракцией, которая называется контроллер (Controller).

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  <...>
```

Когда Pod создается, он по плану (за это отвечает scheduler) запускается на одной из нод кластера Kubernetes. На этой ноде Pod остается до тех пор, пока:

- Не завершится процесс внутри Pod'а (например, если это одноразовая задача);
- Pod не будет удален вручную;
- Pod не будет «выселен» из ноды из-за нехватки ресурсов;
- Нода не выйдет из строя.

**Примечание**. Перезапуск контейнера внутри Pod'а не следует путать с перезапуском самого Pod'а.

Сами по себе Pod'ы не являются «самолечащимися» (self-healing) объектами. Если запуск Pod'а запланирован на ноде, которая вышла из строя, или сама операция запуска потерпела крах, то Pod удаляется.

Теплейт описания Pod'ы описывается в формате *.yml. Запуск темплейта:

```bash
$ kubectl create -f jenkins-pod.yml
jenkins-pod created.
```

## Network

Каждому Pod'у присваивается IP-адрес. Внутри Pod'а каждый контейнер использует общее пространство имен (namespace) сети, включая IP-адрес и сетевые порты. Между собой внутри Pod'а контейнеры взаимодействуют через localhost. При взаимодействии с объектами, находящимися за пределами Pod'а, контейнеры «договариваются» между собой и координируют использование общих сетевых ресурсов (таких как порты).

```bash
$ kubectl describe pod -n ingress-nginx                     
Name:         nginx-ingress-controller-568867bf56-7l7c5       
Namespace:    ingress-nginx                                   
Priority:     0                                               
Node:         master/192.168.100.51                           
Start Time:   Mon, 11 Nov 2019 12:13:28 +0300                 
Labels:       app.kubernetes.io/name=ingress-nginx            
              app.kubernetes.io/part-of=ingress-nginx         
              pod-template-hash=568867bf56                    
Annotations:  prometheus.io/port: 10254                       
              prometheus.io/scrape: true                      
Status:       Running                                         
IP:           10.244.0.11                                     
IPs:                                                          
  IP:           10.244.0.11                                   
Controlled By:  ReplicaSet/nginx-ingress-controller-568867bf56
Containers:
  nginx-ingress-controller:
    <...>
    Ports:         80/TCP, 443/TCP
    Host Ports:    0/TCP, 0/TCP
    <...>
```

## Volume

Pod может определить набор общих томов (**volumes**) для хранения данных. Контейнеры внутри Pod'а могут обмениваться данными между собой при помощи томов. При помощи томов можно сохранить данные, если один из контейнеров Pod'а (которому нужны эти данные для корректной работы) будет перезапущен.

Время жизни томов = времени жизни Pod'а.

```bash
$ kubectl describe pod -n ingress-nginx                     
<...>
Volumes:                                                          
  nginx-ingress-serviceaccount-token-xv4x7:                       
    Type:        Secret (a volume populated by a Secret)          
    SecretName:  nginx-ingress-serviceaccount-token-xv4x7         
    Optional:    false     
<...>                                       
```

## ReplicaSet

**ReplicaSet** гарантирует, что определенное количество экземпляров под (Pods) будет запущено в кластере Kubernetes в любой момент времени.

ReplicaSet – это следующее поколение Replication Controller. Единственная разница между ReplicaSet и Replication Controller – поддержка селектора. ReplicaSet поддерживает множественный выбор в селекторе, тогда как Replication Controller поддерживает в селекторе только выбор на основе равенства.

```bash
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: frontend
  labels:
    app: guestbook
    tier: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: frontend
    matchExpressions:
      - {key: tier, operator: In, values: [frontend]}
  template:
    metadata:
      labels:
        app: guestbook
        tier: frontend
    spec:
      containers:
      - name: php-redis
        image: gcr.io/google_samples/gb-frontend:v3
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: env
        ports:
        - containerPort: 80
```

Запускаем темплейт приведённый выше:

```bash
$ kubectl create -f guestbooks-rc.yml 
replicaset.apps/frontend created
```

Проверим состояние:

```bash
$ kubectl describe replicaset.apps/frontend
Name:         frontend
Namespace:    default
Selector:     tier=frontend,tier in (frontend)
Labels:       app=guestbook
              tier=frontend
Annotations:  <none>
Replicas:     3 current / 3 desired
Pods Status:  3 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=guestbook
           tier=frontend
  Containers:
   php-redis:
    Image:      gcr.io/google_samples/gb-frontend:v3
    Port:       80/TCP
    Host Port:  0/TCP
    Requests:
      cpu:     100m
      memory:  100Mi
    Environment:
      GET_HOSTS_FROM:  env
    Mounts:            <none>
  Volumes:             <none>
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  3m12s  replicaset-controller  Created pod: frontend-4btm7
  Normal  SuccessfulCreate  3m12s  replicaset-controller  Created pod: frontend-6cz7n
  Normal  SuccessfulCreate  3m12s  replicaset-controller  Created pod: frontend-s76hb
```

Чистим за собой:

```bash
$ kubectl delete replicaset.apps/frontend
replicaset.apps "frontend" deleted
```

Альтернативы использования ReplicaSet:
- Deployment (рекомендуемый);
- Job (для под, которые должны «завершаться» самостоятельно после выполнения определенной задачи);
- DaemonSet (для запуска под на каждой ноде кластера).

## Deployments

Контроллер развертывания (Deployment controller) предоставляет возможность декларативного обновления для объектов типа поды (Pods) и наборы реплик (ReplicaSets).

Обязательные поля в yaml-темплейте:

- apiVersion – версия API K8s;
- kind – тип объекта Deployment, ReplicaSet, Pod & etc;
- metadata – содержит метаданные name, labels;
- spec – описание спецификаций деплоймента – containers, env, ports & etc.

В поле spec.strategy необходимо определить стратегию обновления Pod. Допустимые значения для данного поля:

- Recreate. Перед стартом новых Pod все старые будут удалены.
- RollingUpdate (значение по умолчанию). Плавное обновление Pod по очереди (контролировать процесс можно с помощью параметров maxUnavailable и maxSurge).

Пример Deployment:

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
```

- **kind** – создается развертывание (Deployment);
- **metadata**: name – имя nginx-deployment;
- **replicas** – развертывание создает три экземпляра пода;
- **selector** – в поле указано, как развертывание (Deployment) обнаружит, какими подами (Pods) нужно управлять. В этом примере просто выбираем одну метку, определенную в шаблоне Pod‘а (app: nginx);
- **template**: spec: container – запустить docker-контейнер nginx, из образа nginx версии 1.7.9 (образ будет взят с Docker Hub). Данному поду будет присвоена метка app: nginx;
- **template**: spec: container: port – развертывание открывает 80-й порт контейнера.

Горизонтальное масштабирование под (Horizontal Pod Autoscaler):

```bash
$ kubectl autoscale deployment nginx-deployment --min=10 --max=15 --cpu-percent=80
deployment "nginx-deployment" autoscaled
```

## Garbage Collector

Сборщика мусора (**Garbage Collector**) удаляет объекты, которые больше не имеют владельца.

Каскадное удаление (**Сascading Deletion**) – при удалении объекта-владельца есть возможность автоматически удалять зависимые объекты. Каскадное удаление бывает:

- Фоновое (**background**). Немедленно удаляется объект-владелец, а сборщик мусора (Garbage Collector) удаляет зависимые объекты в фоновом режиме.
- Приоритетное (**foreground**). Объект-владелец сначала переходит в состояние «удаление в процессе» (deletion in progress). В этом состоянии выполняется следующее:
  - Объект по-прежнему можно увидеть через REST API;
  - Устанавливается значение deletionTimestamp объекта;
  - Поле metadata.finalizers содержит значение «foregroundDeletion».

После перехода объекта-владельца в состояние «удаление в процессе» сборщик мусора (Garbage Collector) удаляет зависимые объекты. Как только будут удалены все блокирующие зависимости (объекты с ownerReference.blockOwnerDeletion=true), сборщик мусора удалит и объект-владелец.

Если при удалении объекта-владельца зависимые объекты не удаляются автоматически, то они становятся осиротевшими (orphaned).
Оставить зависимые объекты в кластере с помощью ключ --cascade=false (по умолчанию true).

```bash
$ kubectl delete replicaset my-repset --cascade=false
```

## K8s PHP Guestbook diagram
![k8s diagramm](https://github.com/Cyberglamdring/4employers/blob/master/Kubernetes/etc/k8s_Guestbook_diagram.png?raw=true)

## Cписок источников

- Официальный вебсайт kubernetes.io https://kubernetes.io/docs
- Блог https://ealebed.github.io/tags/kubernetes/
- Хабр – Основы Кубернетес https://habr.com/ru/post/258443/