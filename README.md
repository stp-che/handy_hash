# HandyHash

`HandyHash` - это небольшая обертка для `Hash`, которая может быть весьма удобна в некоторых случаях.

Возможности:

- доступ к данным через методы-геттеры (см. Использование)
- рекурсивный `freeze`
- рекурсивное слияние + специальный DSL для описания слияния (см. Использование)

## Установка

Добавить в Gemfile слудющую строку:

```ruby
gem 'handy_hash'
```

Запустить:

    $ bundle

Или установить гем вручную:

    $ gem install handy_hash

## Использование

Инициализация:

```ruby
  data = HandyHash.new(
    host_name: 'www.myapp.com',
    some_lib: {
      path: '/lib/some_lib',
      init_opts: {
        flags: 3465873,
        secret: "78396nxry837d"
      },
      methods: %w(one two)
    }
  )
```

Получать значения можно разными способами.

Как из обычного хэша (работает как `HashWithIndifferentAccess`):

```ruby
  data[:host_name]                      # => "www.myapp.com"
  data["some_lib"][:init_opts]          # => {"flags" => 3465873, "secret" => "78396nxry837d"}
  data["some_lib"]["init_opts"][:flags] # => 3465873
```

В этом случае никакой проверки на присутствие элемента не производится:

```ruby
  data[:foo]        # => nil
  data[:foo][:bar]  # => NoMethodError: undefined method `[]' for nil:NilClass
```

Можно получать значения, используя геттеры:

```ruby
  data.host_name                  # => "www.myapp.com"
  data.some_lib.init_opts         # => {"flags" => 3465873, "secret" => "78396nxry837d"}
  data.some_lib.init_opts[:flags] # => 3465873
  data.some_lib.init_opts.secret  # => "78396nxry837d"
```

В этом случае можно "безопасно" спускаться на любую глубину, не опасаясь возникновения исключения:

```ruby
  data.foo.present?         # => false
  data.foo.bar.baz.present? # => false
  data.foo.bar[:baz]        # => nil
```

Есть возможность принудительно вызвать исключение приотсутствии определенного элемента:

```ruby
  data.some_lib.path! # => "/lib/some_lib"
  data.foo!.bar       # => HandyHash::ValueMissingError: value missing: "foo"
```

В качестве аргумента можно передать значение по умолчанию:

```ruby
  data.some_lib.init_opts.flags(0) # => 3465873
  data.foo.bar.baz(666)            # => 666
```

Если ключ хэша соответствует названию какого-то существующего метода объекта `HandyHash` (например, `methods`, `hash`, `patch` и т.д.), то необходимо оборачивать метод знаком `_`:

```ruby
  data.some_lib._methods_ # => ["one", "two"]
```

### Слияние (переопределение значений)

Слияние производится с помощью метода `#patch`, который возвращает новый объект `HandyHash` с новыми значениями. Значения в исходном объекте не меняются.

Слияние производится рекурсивно во всех нижележащих `Hash`-объектах.

Выполнить слияние можно, передав методу `#patch` объект `Hash`:

```ruby
  new_data = data.patch(
    some_lib: {
      path: '/lib/other_path'
    },
    foo: :bar
  )
  new_data.some_lib.path # => '/lib/other_path'
  new_data.foo           # => :bar
```

Можно с помощью DSL:

```ruby
  new_data = data.patch{
    some_lib {
      path '/lib/other_path'
    }
    foo :bar
  }
  new_data.some_lib.path # => '/lib/other_path'
  new_data.foo           # => :bar
```

Для экономии строк при изменениях значений на глубоких уровнях иерархии можно использовать цепочки методов:

```ruby
  new_data = data.patch{
    some_lib.init_opts.secret 'abc'
    foo.bar.baz 123
  }
  new_data.some_lib.init_opts.secret # => "abc"
  new_data.foo.bar.baz               # => 123
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/stp-che/handy_hash.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

