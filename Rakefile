require 'rake/clean'

EYAML_FILES = FileList['kubernetes/**/*.eyaml']
CLEAN.include(EYAML_FILES.ext('.yaml'))

rule '.yaml' => '.eyaml' do |t|
  puts "#{t.name} #{t.source}"
  sh "eyaml decrypt -f #{t.source} > #{t.name}"
end

def sh_quiet(script)
  sh script do |ok, res|
    unless ok
      # exit without verbose rake error message
      exit res.exitstatus
    end
  end
end

def tf_cmd(deploy, name, arg)
  task name do
    sh_quiet <<-EOS
      cd terraform/#{deploy}
      ../bin/terraform get
      ../bin/terraform #{arg}
    EOS
  end
end

def tf_bucket_region
  "us-west-2"
end

def env_prefix
  env = ENV['TF_VAR_env_name']

  if env.nil?
    abort('env var TF_VAR_env_name must be defined')
  end

  if env == 'prod'
    env = 'conda-mirror'
  else
    env = "#{env}-conda-mirror"
  end

  env
end

def tf_bucket
  "#{env_prefix}.lsst.codes-tf"
end

def tf_remote(deploy)
  desc 'configure remote state'

  task 'remote' do
    remote = 'init' +
      " -backend=true" +
      " -backend-config=\"region=#{tf_bucket_region}\"" +
      " -backend-config=\"bucket=#{tf_bucket}\"" +
      " -backend-config=\"key=#{deploy}/terraform.tfstate\"" +
      " -input=false" +
      " -get=true"

      sh_quiet <<-EOS
        cd terraform/#{deploy}
        ../bin/terraform #{remote}
      EOS
    end
end

namespace :terraform do
  namespace :bucket do
    desc 'create s3 bucket to hold remote state'
    task :create do
     sh_quiet "aws s3 mb s3://#{tf_bucket} --region #{tf_bucket_region}"
    end
  end

  desc 'download terraform'
  task :install do
    sh_quiet <<-EOS
      cd terraform
      make
    EOS
  end

  desc 'configure remote state on s3 bucket'
  task :remote => [
    'terraform:bucket:create',
    'terraform:cmirror:remote',
  ]

  namespace :cmirror do
    deploy = 'cmirror'

    desc 'apply'
    tf_cmd(deploy, :apply, 'apply')
    desc 'destroy'
    tf_cmd(deploy, :destroy, 'destroy -force')
    tf_remote(deploy)
  end # :s3
end

def tf_output(path)
  output = nil
  Dir.chdir(path) do
    output = JSON.parse(`../bin/terraform output -json`)
  end
  output
end

namespace :jenkins do
  desc 'print jenkins hiera yaml'
  task 'creds' do
    require 'yaml'
    require 'json'

    cm_output  = tf_output('terraform/cmirror')

    creds = {
      'aws-cmirror-push' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'UsernamePasswordCredentialsImpl',
        'description' => 'push conda packages -> s3',
        'username'    => "DEC::PKCS7[#{cm_output['CMIRROR_PUSH_AWS_ACCESS_KEY_ID']['value']}]!",
        'password'    => "DEC::PKCS7[#{cm_output['CMIRROR_PUSH_AWS_SECRET_ACCESS_KEY']['value']}]!",
      },
      'cmirror-s3-bucket' => {
        'domain'      => nil,
        'scope'       => 'GLOBAL',
        'impl'        => 'StringCredentialsImpl',
        'description' => 'name of conda channel bucket',
        'secret'      => cm_output['CMIRROR_S3_BUCKET']['value'],
      },
    }
    puts YAML.dump(creds)
  end
end

desc 'write creds.sh'
task :creds do
  File.write('creds.sh', <<-EOS.gsub(/^\s+/, '')
    export AWS_ACCESS_KEY_ID=#{ENV['AWS_ACCESS_KEY_ID']}
    export AWS_SECRET_ACCESS_KEY=#{ENV['AWS_SECRET_ACCESS_KEY']}
    export AWS_DEFAULT_REGION=us-east-1
    export TF_VAR_aws_access_key=$AWS_ACCESS_KEY_ID
    export TF_VAR_aws_secret_key=$AWS_SECRET_ACCESS_KEY
    export TF_VAR_aws_default_region=$AWS_DEFAULT_REGION
    export TF_VAR_env_name=#{ENV['USER']}-dev
    EOS
  )
end

task :default => [
  'terraform:install',
]

desc 'destroy all tf/kube resources'
task :destroy => [
  'terraform:cmirror:destroy',
]
