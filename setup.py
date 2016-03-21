from setuptools import setup

broker_name = 'prom'
pkg_name = 'robot_tests.broker.{}'.format(broker_name)

setup(name=pkg_name,
      version='0.0.dev1',
      description='{} broker for OpenProcurement Robot tests'.format(broker_name),
      author='',
      author_email='',
      url='https://github.com/openprocurement/{}'.format(pkg_name),
      packages=[pkg_name],
      package_dir={pkg_name: '.'},
      package_data={pkg_name: ['*.robot']}
      )
