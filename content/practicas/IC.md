+++
title = "Introducción a la integración continua "
description = ""
tags = [
    "IWEB"
]
date = "2021-06-04"
menu = "main"
+++

### Integración continúa de aplicación django

* Ya tenemos nuestra aplicación y el entorno virtual de la práctica de [Despliegue de una aplicación python](https://alepeteporico.github.io/practicas/despliegue_python/) usaremos la misma, y realizaremos los test.

        (django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ python3 manage.py test
        Creating test database for alias 'default'...
        System check identified no issues (0 silenced).
        ..........
        ----------------------------------------------------------------------
        Ran 10 tests in 0.056s

        OK
        Destroying test database for alias 'default'...

* Vamos a modificar el fichero `polls/templates/polls/index.html` para provocar un error, por ejemplo quitando unas llaves provocando así un error de sintaxis.

        {% load static %}

        <link rel="stylesheet" type="text/css" href="{% static 'polls/style.css' %}">

        % if latest_question_list %}
            <ul>
            {% for question in latest_question_list %}
            <li><a href="{% url 'polls:detail' question.id %}">{{ question.question_text }}</a></li>
            {% endfor %}
            </ul>
        {% else %}
            <p>No polls are available.</p>
        {% endif %}

* Al hacer el test de nuevo vemos que se produce un error.

        (django) alejandrogv@AlejandroGV:~/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial$ python3 manage.py test
        Creating test database for alias 'default'...
        System check identified no issues (0 silenced).
        ..EEEEE...
        ======================================================================
        ERROR: test_future_question (polls.tests.QuestionIndexViewTests)
        ----------------------------------------------------------------------
        Traceback (most recent call last):
          File "/home/alejandrogv/Escritorio/ASIR/IWEB/django/lib/python3.7/site-packages/django/template/base.py", line 470, in parse
            compile_func = self.tags[command]
        KeyError: 'else'

        During handling of the above exception, another exception occurred:

        Traceback (most recent call last):
          File "/home/alejandrogv/Escritorio/ASIR/IWEB/despliegue_python/django_tutorial/polls/tests.py", line 72, in test_future_question
            response = self.client.get(reverse('polls:index'))
          File "/home/alejandrogv/Escritorio/ASIR/IWEB/django/lib/python3.7/site-packages/django/test/client.py", line 733, in get
            response = super().get(path, data=data, secure=secure, **extra)
          File "/home/alejandrogv/Escritorio/ASIR/IWEB/django/lib/python3.7/site-packages/django/test/client.py", line 395, in get
            **extra,
          File "/home/alejandrogv/Escritorio/ASIR/IWEB/django/lib/python3.7/site-packages/django/test/client.py", line 470, in generic
            return self.request(**r)
          File "/home/alejandrogv/Escritorio/ASIR/IWEB/django/lib/python3.7/site-packages/django/test/client.py", line 710, in request
          ...
          ...
          ...

* Ahora vamos a configurar la integración continua, para cada vez que se realice un commit se realize un test en la herramienta que elijamos de integración continua, en mi caso he elegido GitHub Actions. para usar esta funcionalidad debemos entrar en nuestra cuenta de GitHub, y el repositorio de nuestra aplicación nos dirigimos a `Actions > set up a workflow yourself`

![ic](/IC/1.png)

* Una vez cliquemos ahí nos aparecerá un fichero llamado `main.yml` que editaremos de la siguiente forma:

~~~
# This is a basic workflow to help you get started with Actions

name: CI

# Controls when the action will run. 
on:
  # Triggers the workflow on push or pull request events but only for the master branch
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

  jobs:
    build:

      runs-on: ubuntu-latest
      strategy:
        matrix:
          python-version: [3.9]

      steps:
      - uses: actions/checkout@v2
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v2
        with:
          python-version: ${{ matrix.python-version }}
      - name: Requerimientos
        run: |
          pip install --upgrade pip
          pip install -r requirements.txt

      - name: Prueba python3
        run: python3 manage.py test
~~~

* Vamos a comprobar un commit con todo correcto.

![bien](/IC/2.png)

* Y uno con un fallo en el test.

![fallo](/IC/3.png)

* Vemos que nuestro metodo de integración continua funciona, ahora vamos a implementarlo en un hosting Heroku.  Nos dirigiremos en nuestra cuenta a las propiedades y copiaremos una clave llamada `API Key`.

![key](/IC/4.png)

* Seguidamente nos dirigiremos a nuetro repositorio en GitHub a `settings > secrets` y añadimos un nuevo "secreto".

![secreto](/IC/5.png)

* Añadiremos un nuevo proyecto en heroku que conectaremos con nuestro repositorio.

![rep](/IC/6.png)

* Modificamos un poco nuestro fichero `main.yml`.

        # This is a basic workflow to help you get started with Actions

        name: CI

        # Controls when the action will run. 
        on:
          # Triggers the workflow on push or pull request events but only for the master branch
          push:
            branches: [ master ]
          pull_request:
            branches: [ master ]

        jobs:
          build:

            runs-on: ubuntu-latest
            strategy:
              matrix:
                python-version: [3.9]

            steps:
            - uses: actions/checkout@v2
            - name: akhileshns/heroku-deploy@v3.8.9
              uses: actions/setup-python@v2
              with:
                  heroku_api_key: ${{secrets.HEROKU}}
                  heroku_app_name: "integracion" 
                  heroku_email: "tojandro@gmail.com"
                  procfile: "web: npm start"    
            - name: Requerimientos
              run: |
                pip install --upgrade pip
                pip install -r requirements.txt

            - name: Prueba python3
              run: python3 manage.py test

* También debemos modificar el fichero `settings.py` añadiendo esto en la primera línea.

        import os

* Y esto en la última.

        STATIC_ROOT = os.path.join(BASE_DIR, 'static')

* Y ya tendriamos implementada la integracion en heroku.