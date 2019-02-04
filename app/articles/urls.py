from django.urls import path

from . import views

urlpatterns = [
    path('', views.articles, name='articles'),
    path('<int:article_id>', views.article_ops, name='article_ops'),
]
