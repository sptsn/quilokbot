# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.create(
  login:                 'spitsyn',
  password:              'bcd307368ba5c60d60d0816b94a2a2a22def4f97397a608991510e4917e5a09b',
  password_confirmation: 'bcd307368ba5c60d60d0816b94a2a2a22def4f97397a608991510e4917e5a09b',
  first_name:            'Александр',
  last_name:             'Спицын',
  telegram_id:           '3002462',
  telegram_username:     'aspitsyn'
)

User.create(
  login:                 'papin',
  password:              '766fb6432ae0418815024258010804953500b23e88bb52fdf864fc3ba1f24d91',
  password_confirmation: '766fb6432ae0418815024258010804953500b23e88bb52fdf864fc3ba1f24d91',
  first_name:            'Саша',
  last_name:             'Папин',
  telegram_id:           '47153898',
  telegram_username:     'quilok'
)
