from rest_framework import serializers
from .models import Article


class ArticleSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)
    title = serializers.CharField(required=True, max_length=200)
    text = serializers.CharField(required=False, allow_blank=True, default='')
    archive = serializers.BooleanField(default=False)

    def create(self, validated_data):
        """
        Create and return a new `Article` instance, given the validated data.
        """
        return Article.objects.create(**validated_data)

    def update(self, instance, validated_data):
        """
        Update and return an existing `Article` instance, given the validated data.
        """
        instance.title = validated_data.get('title', instance.title)
        instance.text = validated_data.get('text', instance.text)
        instance.archive = validated_data.get('archive', instance.archive)
        instance.save()
        return instance

    class Meta:
        model = Article
        fields = '__all__'
