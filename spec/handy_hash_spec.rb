require 'spec_helper'

describe HandyHash do
  let(:data){
    HandyHash.new(
      host_name: 'www.myapp.com',
      some_lib: {
        path: '/lib/some_lib',
        init_opts: {
          flags: 3465873,
          secret: "78396nxry837d"
        },
        methods: %w(one two)
      },
      the_false_value: false
    )
  }

  it 'works like hash with indifferent access' do
    expect(data[:host_name]).to eq "www.myapp.com"
    expect(data["some_lib"][:init_opts]).to eq "flags" => 3465873, "secret" => "78396nxry837d"
    expect(data["some_lib"]["init_opts"][:flags]).to eq 3465873
    expect(data[:the_false_value]).to be false
    expect(data[:foo]).to be_nil
  end

  describe 'getters' do
    it 'returns values from hash' do
      expect(data.host_name).to eq "www.myapp.com"
      expect(data.some_lib.init_opts).to eq "flags" => 3465873, "secret" => "78396nxry837d"
      expect(data.some_lib.init_opts[:flags]).to eq 3465873
      expect(data.some_lib.init_opts.secret).to eq "78396nxry837d"
      expect(data.the_false_value).to be false
    end

    it 'does not raise error when digging too deeply' do
      expect(data.foo).to be_blank
      expect(data.foo.bar.baz).to be_blank
      expect(data.foo.bar[:baz]).to be_nil
    end

    context 'when key is a standard Object method' do
      specify 'one have to wrap getter with "_"' do
        expect(data.some_lib._methods_).to eq ["one", "two"]
      end
    end

    context 'calling with !' do
      it 'return values from hash' do
        expect(data.some_lib.init_opts.secret!).to eq "78396nxry837d"
        expect(data.some_lib!.init_opts.flags).to eq 3465873
      end

      it 'raises error when value is not present' do
        expect{ data.foo! }.to raise_error HandyHash::ValueMissingError
        expect{ data.some_lib.foo! }.to raise_error HandyHash::ValueMissingError
      end
    end

    context 'calling with one argument' do
      it 'returns value from hash' do
       expect(data.some_lib.init_opts.flags(0)).to eq 3465873
      end

      it 'returns given argument if value is blank' do
       expect(data.foo.bar.baz(666)).to eq 666
      end
    end
  end

  describe '#freeze' do
    it 'works recursively and freezes values' do
      data.freeze
      expect{
        expect{ data[:host_name] = 'aaa' }.to raise_error RuntimeError
      }.to_not change{ data.host_name }
      expect {
        expect{ data.some_lib.init_opts[:flags] = 123 }.to raise_error RuntimeError
      }.to_not change{ data.some_lib.init_opts.flags }
      expect {
        expect{ data.some_lib.path << 'fff' }.to raise_error RuntimeError
      }.to_not change{ data.some_lib.path }
    end
  end

  describe '#patch' do
    let(:patched1){
      data.patch(
        some_lib: {
          path: '/lib/other_path'
        },
        foo: :bar
      )
    }
    let(:patched2){
      data.patch{
        some_lib {
          init_opts.flags 123
        }
        foo :bar
      }
    }

    it 'changes values' do
      expect(patched1.some_lib.path).to eq '/lib/other_path'
      expect(patched1.foo).to eq :bar
      expect(patched2.some_lib.init_opts.flags).to eq 123
      expect(patched2.foo).to eq :bar
    end

    it 'leaves unmentioned values' do
      expect(patched1).to include(
        'host_name' => 'www.myapp.com',
        'some_lib' => include(
          'init_opts' => {
            'flags' => 3465873,
            'secret' => "78396nxry837d"
          },
          'methods' => %w(one two)
        )
      )
      expect(patched2).to include(
        'host_name' => 'www.myapp.com',
        'some_lib' => {
          'path' => '/lib/some_lib',
          'init_opts' => include(
            'secret' => "78396nxry837d"
          ),
          'methods' => %w(one two)
        }
      )
    end

    it 'does not change the original' do
      patched1
      patched2
      
      expect(data).to match(
        host_name: 'www.myapp.com',
        some_lib: {
          path: '/lib/some_lib',
          init_opts: {
            flags: 3465873,
            secret: "78396nxry837d"
          },
          methods: %w(one two)
        },
        the_false_value: false
      )
    end
  end


end
