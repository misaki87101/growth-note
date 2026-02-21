# syntax = docker/dockerfile:1
ARG RUBY_VERSION=3.2.2
FROM docker.io/library/ruby:$RUBY_VERSION-slim

# 1. 必要な道具を全部一気に入れる
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    curl \
    libpq-dev \
    libvips \
    postgresql-client \
    git \
    nodejs \
    npm && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 2. アプリの場所を設定
WORKDIR /rails

# 3. 開発環境用の設定
ENV RAILS_ENV="development" \
    BUNDLE_PATH="/usr/local/bundle"

# 4. Gemのインストール
COPY Gemfile Gemfile.lock ./
# 開発モードなので --deployment は外します
RUN bundle install

# 5. アプリコードをコピー
COPY . .

# 6. サーバー起動設定
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]