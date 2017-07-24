all: | docker-down clone-drupal docker-up drupal-install

docker-down:
	docker-compose down

clone-drupal:
	if [ ! -d "drupal" ]; then git clone git://git.drupal.org/project/drupal.git; fi

docker-up:
	docker-compose up -d

drupal-install:
	composer install -d ./drupal
	sleep 20
	docker-compose exec -T php /bin/sh -c "drush si testing --root=web --db-url=mysql://drupal:drupal@mariadb/drupal --account-pass=admin -y"
	docker-compose exec -T php /bin/sh -c "drush en --root=web simpletest -y"
	docker-compose exec php /bin/sh -c "chown www-data:www-data /var/www/html -R"

run-test:
	docker-compose exec php /bin/sh -c "su - www-data -c '/usr/local/bin/php /var/www/html/web/core/scripts/run-tests.sh --verbose --url http://nginx/ --sqlite /tmp/tests.sqlite --class \"$(function)\"'"
