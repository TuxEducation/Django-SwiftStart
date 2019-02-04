# To run server in development mode
# python manage.py runserver --settings=main.settings.development

from .base import *

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = 'l%e)(hm!(cohva6)o6rvgy61(=k95+qy6lhc1y2+7o&dih67l+'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# Database
# https://docs.djangoproject.com/en/2.1/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'scaffolding_development',
        'USER': 'root',
        'PASSWORD': 'root',
        'HOST': '127.0.0.1',
        'ATOMIC_REQUESTS': True,
    }
}

EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
