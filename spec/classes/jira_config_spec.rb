require 'spec_helper.rb'

describe 'jira' do
  describe 'jira::config' do
    context 'supported operating systems' do
      on_supported_os.each do |os, facts|
        context "on #{os} #{facts}" do
          let(:facts) do
            facts
          end
          context 'default params' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/bin/setenv.sh')
                .with_content(/#DISABLE_NOTIFICATIONS=/)
            end
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/bin/user.sh') }
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml') }
            it do
              should contain_file('/home/jira/dbconfig.xml')
                .with_content(%r{<url>jdbc:postgresql://localhost:5432/jira</url>})
                .with_content(%r{<schema-name>public</schema-name>})
            end
            it { should_not contain_file('/home/jira/cluster.properties') }
          end

          context 'mysql params' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :db       => 'mysql',
              }
            end
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/bin/setenv.sh') }
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/bin/user.sh') }
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml') }
            it do
              should contain_file('/home/jira/dbconfig.xml')
                .with_content(%r{<url>jdbc:mysql://localhost:5432/jira\?useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=storage_engine=InnoDB</url>})
            end
          end

          context 'sqlserver params' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :db       => 'sqlserver',
                :dbport   => '1433',
                :dbschema => 'public',
              }
            end
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/bin/setenv.sh') }
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/bin/user.sh') }
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml') }
            it do
              should contain_file('/home/jira/dbconfig.xml')
                .with_content(%r{<schema-name>public</schema-name>})
            end
          end

          context 'custom dburl' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :dburl    => 'my custom dburl',
              }
            end
            it do
              should contain_file('/home/jira/dbconfig.xml')
                .with_content(%r{<url>my custom dburl</url>})
            end
          end

          context 'customise tomcat connector' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatPort => '9229',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/<Connector port=\"9229\"\s+maxThreads=/m)
            end
          end

          context 'server.xml listeners' do
            context 'default version' do
              let(:params) do
                {
                  :version  => '6.3.4a',
                  :javahome => '/opt/java',
                }
              end
              it do
                should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                  .with_content(/<Listener className=\"org.apache.catalina.core.JasperListener\"/)
              end
            end

            context 'version greater than 7' do
              let(:params) do
                {
                  :version  => '7.0.4',
                  :javahome => '/opt/java',
                }
              end
              it do
                should contain_file('/opt/jira/atlassian-jira-software-7.0.4-standalone/conf/server.xml')
                  .with_content(/<Listener className=\"org.apache.catalina.core.JreMemoryLeakPreventionListener\"/)
              end
            end
          end

          context 'customise tomcat connector with a binding address' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatPort => '9229',
                :tomcatAddress => '127.0.0.1'
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/<Connector port=\"9229\"\s+address=\"127\.0\.0\.1\"\s+maxThreads=/m)
            end
          end

          context 'tomcat context path' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :contextpath => '/jira',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(%r{<Context path=\"/jira\" docBase=\"\${catalina.home}/atlassian-jira\" reloadable=\"false\" useHttpOnly=\"true\">})
            end
          end

          context 'tomcat port' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatPort => '8888',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/port="8888"/)
            end
          end

          context 'tomcat acceptCount' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatAcceptCount => '200',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/acceptCount="200"/)
            end
          end

          context 'tomcat MaxHttpHeaderSize' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatMaxHttpHeaderSize => '4096',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/maxHttpHeaderSize="4096"/)
            end
          end

          context 'tomcat MinSpareThreads' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatMinSpareThreads => '50',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/minSpareThreads="50"/)
            end
          end

          context 'tomcat ConnectionTimeout' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatConnectionTimeout => '25000',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/connectionTimeout="25000"/)
            end
          end

          context 'tomcat EnableLookups' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatEnableLookups => 'true',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/enableLookups="true"/)
            end
          end

          context 'tomcat Protocol' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatProtocol => 'HTTP/1.1',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(%r{protocol="HTTP/1.1"})
            end
          end

          context 'tomcat UseBodyEncodingForURI' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatUseBodyEncodingForURI => 'false',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/useBodyEncodingForURI="false"/)
            end
          end

          context 'tomcat DisableUploadTimeout' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatDisableUploadTimeout => 'false',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/disableUploadTimeout="false"/)
            end
          end

          context 'tomcat EnableLookups' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatEnableLookups => 'true',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/enableLookups="true"/)
            end
          end

          context 'tomcat maxThreads' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatMaxThreads => '300',
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                .with_content(/maxThreads="300"/)
            end
          end

          context 'tomcat proxy path' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :proxy => {
                  'scheme'    => 'https',
                  'proxyName' => 'www.example.com',
                  'proxyPort' => '9999',
                },
              }
            end
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
              .with_content(/proxyName = 'www\.example\.com'/)
              .with_content(/scheme = 'https'/)
              .with_content(/proxyPort = '9999'/)
            }
          end

          context 'ajp proxy' do
            context 'with valid config including protocol AJP/1.3' do
              let(:params) do
                {
                  :version => '6.3.4a',
                  :javahome => '/opt/java',
                  :ajp => {
                    'port' => '8009',
                    'protocol' => 'AJP/1.3',
                  },
                }
              end
              it do
                should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                  .with_content(%r{<Connector enableLookups="false" URIEncoding="UTF-8"\s+port = "8009"\s+protocol = "AJP/1.3"\s+/>})
              end
            end
            context 'with valid config including protocol org.apache.coyote.ajp.AjpNioProtocol' do
              let(:params) do
                {
                  :version => '6.3.4a',
                  :javahome => '/opt/java',
                  :ajp => {
                    'port' => '8009',
                    'protocol' => 'org.apache.coyote.ajp.AjpNioProtocol',
                  },
                }
              end
              it do
                should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
                  .with_content(%r{<Connector enableLookups="false" URIEncoding="UTF-8"\s+port = "8009"\s+protocol = "org.apache.coyote.ajp.AjpNioProtocol"\s+/>})
              end
            end
          end

          context 'context resources' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :resources => { 'testdb' => { 'auth' => 'Container' } },
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/context.xml')
                .with_content(%r{<Resource name = "testdb"\n        auth = "Container"\n    />})
            end
          end

          context 'disable notifications' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :disable_notifications => true,
              }
            end
            it do
              should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/bin/setenv.sh')
                .with_content(/^DISABLE_NOTIFICATIONS=/)
            end
          end

          context 'native ssl support default params' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatNativeSsl => true,
              }
            end
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
              .with_content(/redirectPort="8443"/)
              .with_content(/port="8443"/)
              .with_content(/keyAlias="jira"/)
              .with_content(%r{keystoreFile="/home/jira/jira.jks"})
              .with_content(/keystorePass="changeit"/)
              .with_content(/keystoreType="JKS"/)
              .with_content(/port="8443".*acceptCount="100"/m)
              .with_content(/port="8443".*maxThreads="150"/m)
            }
          end

          context 'native ssl support custom params' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :tomcatNativeSsl => true,
                :tomcatHttpsPort => '9443',
                :tomcatAddress => '127.0.0.1',
                :tomcatMaxThreads => '600',
                :tomcatAcceptCount => '600',
                :tomcatKeyAlias => 'keystorealias',
                :tomcatKeystoreFile => '/tmp/keyfile.ks',
                :tomcatKeystorePass => 'keystorepass',
                :tomcatKeystoreType => 'PKCS12',
              }
            end
            it { should contain_file('/opt/jira/atlassian-jira-6.3.4a-standalone/conf/server.xml')
              .with_content(/redirectPort="9443"/)
              .with_content(/port="9443"/)
              .with_content(/keyAlias="keystorealias"/)
              .with_content(%r{keystoreFile="/tmp/keyfile.ks\"})
              .with_content(/keystorePass="keystorepass"/)
              .with_content(/keystoreType="PKCS12"/)
              .with_content(/port="9443".*acceptCount="600"/m)
              .with_content(/port="9443".*maxThreads="600"/m)
              .with_content(/port="9443".*address="127\.0\.0\.1"/m)
            }
          end

          context 'enable secure admin sessions' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :enable_secure_admin_sessions => true,
              }
            end
            it do
              should contain_file('/home/jira/jira-config.properties')
                .with_content(/jira.websudo.is.disabled = false/)
            end
          end

          context 'disable secure admin sessions' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :enable_secure_admin_sessions => false,
              }
            end
            it do
              should contain_file('/home/jira/jira-config.properties')
                .with_content(/jira.websudo.is.disabled = true/)
            end
          end

          context 'jira-config.properties' do
            let(:params) do
              {
                :version  => '6.3.4a',
                :javahome => '/opt/java',
                :jira_config_properties => {
                  'ops.bar.group.size.opsbar-transitions' => '4',
                }
              }
            end
            it { should contain_file('/home/jira/jira-config.properties')
              .with_content(/jira.websudo.is.disabled = false/)
              .with_content(/ops.bar.group.size.opsbar-transitions = 4/)
            }
          end

          context 'enable clustering' do
            let(:params) do
              {
                :version => '6.3.4a',
                :javahome => '/opt/java',
                :datacenter => true,
                :shared_homedir => '/mnt/jira_shared_home_dir'
              }
            end
            it { should contain_file('/home/jira/cluster.properties')
              .with_content(/jira.node.id = \S+/)
              .with_content(%r{jira.shared.home = /mnt/jira_shared_home_dir})
            }
          end
        end
      end
    end
  end
end
