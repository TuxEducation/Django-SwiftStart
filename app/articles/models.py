from django.db import models


class Article(models.Model):
    title = models.CharField(max_length=200, default='')
    text = models.TextField(default='')
    archive = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
