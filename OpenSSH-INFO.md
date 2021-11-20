

# Como blindar o OpenSSH no Ubuntu 18.04 | DigitalOcean

[Source](https://www.digitalocean.com/community/tutorials/how-to-harden-openssh-on-ubuntu-18-04-pt "Permalink to Como blindar o OpenSSH no Ubuntu 18.04 | DigitalOcean")

*O autor selecionou a [Electronic Frontier Foundation, Inc](https://www.brightfunds.org/organizations/electronic-frontier-foundation-inc) para receber uma doação como parte do programa [Write for DOnations](https://do.co/w4do-cta).*

### Introdução

Os servidores Linux são frequentemente administrados remotamente usando o SSH conectando-se a um servidor [OpenSSH](https://www.openssh.com/), que é o software padrão de servidor SSH usado dentro do Ubuntu, Debian, CentOS, FreeBSD e a maioria dos outros sistemas baseados em Linux/BSD.

O servidor OpenSSH é o lado servidor do SSH, também conhecido como SSH daemon ou `sshd`. Você pode se conectar a um servidor OpenSSH usando o cliente OpenSSH — o comando `ssh`. Saiba mais sobre o modelo cliente-servidor do SSH em [SSH Essentials: Working with SSH Servers, Clients, and Keys](https://www.digitalocean.com/community/tutorials/ssh-essentials-working-with-ssh-servers-clients-and-keys). Proteger corretamente seu servidor OpenSSH é muito importante, pois ele atua como a porta frontal ou a entrada em seu servidor.

Neste tutorial, você irá blindar seu servidor OpenSSH usando diferentes opções de configuração para garantir que o acesso remoto ao seu servidor seja o mais seguro possível.

## Pré-requisitos

Para completar este tutorial, você precisará de:

* Um servidor Ubuntu 18.04 configurado seguindo a [Configuração inicial de servidor com o Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04), incluindo um usuário sudo não raiz.

Assim que estiver com tudo pronto, faça login no seu servidor como seu usuário não-root para começar.

## Passo 1 — Blindagem geral

Neste primeiro passo, você irá implementar algumas configurações iniciais de blindagem para melhorar a segurança geral do seu servidor SSH.

A configuração exata de blindagem que é mais adequada para seu servidor depende fortemente do seu próprio [modelo de ameaça e limite de risco](https://owasp.org/www-community/Application_Threat_Modeling). No entanto, a configuração que você irá usar neste passo é uma configuração geral de segurança que irá atender à maioria dos servidores.

Muitas das configurações de blindagem para o OpenSSH, você implementa usando o arquivo padrão de configuração do servidor OpenSSH, que está localizado em `/etc/ssh/sshd_config`. Antes de continuar com este tutorial, recomenda-se fazer um backup do seu arquivo de configuração existente, para que você possa restaurá-lo caso algo dê errado.

Faça um backup do arquivo usando o seguinte comando:

    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

Isso irá salvar uma cópia de backup do arquivo em `/etc/ssh/sshd_config.bak`.

Antes de editar seu arquivo de configuração, você pode revisar as opções que estão atualmente definidas. Para fazer isso, execute o seguinte comando:

    sudo sshd -T

Isso irá executar o servidor OpenSSH em modo de teste estendido, que irá validar o arquivo de configuração completo e imprimir os valores de configuração efetivos.

Agora, você pode abrir o arquivo de configuração usando seu editor de texto favorito para começar a implementar as medidas iniciais de blindagem:

    sudo nano /etc/ssh/sshd_config

**Nota:** o arquivo de configuração do servidor OpenSSH inclui muitas opções e configurações padrão. Dependendo da configuração atual do seu servidor, algumas das opções de blindagem recomendadas podem já ter sido definidas.

Ao editar seu arquivo de configuração, algumas opções podem estar comentadas por padrão usando um único caractere hash (`#`) no início da linha. Para editar essas opções, ou ter a opção comentada sendo reconhecida, você precisará descomentá-las removendo o hash.

Primeiramente, desative o login via SSH como usuário **root** definindo a seguinte opção:

sshd\_config

    PermitRootLogin no

Isso é massivamente benéfico, pois irá impedir que um invasor em potencial faça login diretamente como root. Isso também estimula boas práticas de segurança operacional, como operar como um usuário não privilegiado e usar `sudo` para escalar privilégios somente quando absolutamente necessário.

Em seguida, você pode limitar o número máximo de tentativas de autenticação para uma determinada sessão de login configurando o seguinte:

sshd\_config

    MaxAuthTries 3

Um valor padrão de `3` é aceitável para a maioria das configurações, mas talvez você queira definir isso como maior ou menor, dependendo do seu próprio limite de risco.

Se necessário, você também pode definir um período de carência de login reduzido, que é a quantidade de tempo que um usuário tem para concluir a autenticação depois de se conectar inicialmente ao seu servidor SSH:

sshd\_config

    LoginGraceTime 20

O arquivo de configuração especifica esse valor em segundos.

Definir isso para um valor mais baixo ajuda a prevenir certos [ataques de negação de serviço](https://www.cloudflare.com/learning/ddos/glossary/denial-of-service/), onde várias sessões de autenticação são mantidas abertas por um período prolongado de tempo.

Se você configurou chaves SSH para autenticação, em vez de usar senhas, desative a autenticação de senha SSH para evitar que senhas de usuário vazadas permitam que um invasor faça login:

sshd\_config

    PasswordAuthentication no

Como uma medida adicional de blindagem relacionada às senhas, é possível desativar a autenticação com senhas vazias. Isso irá impedir tentativas de login se a senha de um usuário estiver definida como um valor vazio ou em branco:

sshd\_config

    PermitEmptyPasswords no

Na maioria dos casos de uso, o SSH será configurado com a autenticação de chave pública como o único método de autenticação em uso. No entanto, o servidor OpenSSH também é compatível com muitos outros métodos de autenticação. Alguns deles estão habilitados por padrão. Se estes não forem necessários, você pode desativá-los para que eles reduzam ainda mais a superfície de ataque do seu servidor SSH:

sshd\_config

    ChallengeResponseAuthentication no
    KerberosAuthentication no
    GSSAPIAuthentication no

Se você quiser saber mais sobre alguns dos métodos de autenticação adicionais disponíveis dentro do SSH, confira esses recursos:

* [Autenticação Desafio Resposta](https://en.wikipedia.org/wiki/Challenge%E2%80%93response_authentication)
* [Autenticação Kerberos](https://docstore.mik.ua/orelly/networking_2ndEd/ssh/ch11_04.htm)
* [Autenticação GSSAPI](https://www.ssh.com/manuals/clientserver-product/52/Secureshell-gssapiuserauthentication.html)

O encaminhamento X11 permite a exibição de aplicativos gráficos remotos em uma conexão SSH, mas isso raramente é usado na prática. Recomenda-se desativá-lo se ele não for necessário em seu servidor:

sshd\_config

    X11Forwarding no

O servidor OpenSSH permite conectar clientes para passar variáveis personalizadas de ambiente, ou seja, definir um `$PATH` ou definir configurações de terminal. No entanto, como o encaminhamento X11, esses não são comumente usados, então podem ser desativados na maioria dos casos:

sshd\_config

    PermitUserEnvironment no

Se você decidir configurar essa opção, você também deve certificar-se de comentar quaisquer referências ao `AcceptEnv` adicionando um hash (`#`) ao início da linha.

Em seguida, é possível desativar várias opções relacionadas ao tunelamento e encaminhamento se você não estiver usando essas opções em seu servidor:

sshd\_config

    AllowAgentForwarding no
    AllowTcpForwarding no
    PermitTunnel no

Por fim, você pode desativar o banner detalhado do SSH que está habilitado por padrão, pois ele mostra várias informações sobre seu sistema, como a versão do sistema operacional:

sshd\_config

    DebianBanner no

Observe que essa opção muito provavelmente não estará já presente no arquivo de configuração, então você pode precisar adicioná-la manualmente. Salve e saia do arquivo assim que terminar.

Agora, valide a sintaxe da sua nova configuração executando o `sshd` no modo de teste:

    sudo sshd -t

Se o arquivo de configuração tiver uma sintaxe válida, não haverá nenhuma saída. Em caso de erro de sintaxe, haverá uma saída descrevendo o problema.

Depois que estiver satisfeito com seu arquivo de configuração, você pode recarregar o `sshd` para aplicar as novas configurações:

    sudo service sshd reload

Neste passo, você completou a blindagem geral do seu arquivo de configuração do servidor OpenSSH. Em seguida, você implementará uma lista de permissões de endereços IP para restringir ainda mais quem pode fazer login no seu servidor.

## Passo 2 — Implementando uma lista de permissões de endereço IP

Você pode usar as listas de permissões de endereço IP para limitar os usuários que estão autorizados a fazer login no seu servidor baseado em endereço IP. Neste passo, você irá configurar uma lista de permissões IP para seu servidor OpenSSH.

Em muitos casos, você estará fazendo login em seu servidor apenas a partir um pequeno número de endereços IP conhecidos e confiáveis. Por exemplo, sua conexão de internet em casa, um appliance VPN corporativo, ou um [jump box](https://en.wikipedia.org/wiki/Jump_server) estático ou um [bastion host](https://en.wikipedia.org/wiki/Bastion_host) em um data center.

Ao implementar uma lista de permissões de endereço IP, você garante que as pessoas só poderão fazer login a partir de um dos endereços IP pré-aprovados, reduzindo consideravelmente o risco de uma violação no caso de suas chaves privadas.e/ou senhas vazarem.

**Nota:** tome cuidado em identificar os endereços IP corretos para adicionar à sua lista de permissões e certifique-se de que esses endereços não sejam flutuantes ou dinâmicos que podem mudar regularmente, por exemplo, como é visto frequentemente com provedores de serviços de internet ao consumidor.

Você pode identificar o endereço IP com o qual você está conectando atualmente ao seu servidor usando o comando `w`:

    w

Isso irá gerar algo parecido com o seguinte:

    Output
     14:11:48 up 2 days, 12:25,  1 user,  load average: 0.00, 0.00, 0.00
             USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
    your_username     pts/0    203.0.113.1     12:24    1.00s  0.20s  0.00s w

Localize sua conta de usuário na lista e anote o endereço IP de conexão. Aqui usamos o IP de exemplo `203.0.113.1`

Para começar a implementar sua lista de permissões de endereço IP, abra o arquivo de configuração do servidor OpenSSH em seu editor de texto favorito:

    sudo nano /etc/ssh/sshd_config

Você pode implementar listas de permissões de endereço IP usando a diretiva de configuração `AllowUsers`, que restringe as autenticações de usuário baseadas em nome de usuário e/ou endereço IP.

A configuração e os requisitos de seu próprio sistema determinarão qual configuração específica é a mais apropriada. Os exemplos a seguir irão ajudar você a identificar a mais adequada:

* Restringir todos os usuários a um endereço IP específico:

    AllowUsers *@203.0.113.1

* Restringir todos os usuários a um intervalo de endereços IP específico usando a [notação Classless Inter-Domain Routing (CIDR)](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing):

    AllowUsers *@203.0.113.0/24

* Restringir todos os usuários a um intervalo de endereços IP específico (usando caracteres curingas):

    AllowUsers *@203.0.113.*

* Restringir todos os usuários a vários endereços IP e intervalos específicos:

    AllowUsers *@203.0.113.1 *@203.0.113.2 *@192.0.2.0/24 *@172.16.*.1

* Proibir todos os usuários, exceto para usuários nomeados a partir de endereços IP específicos:

    AllowUsers sammy@203.0.113.1 alex@203.0.113.2<^>

* Restringir um usuário específico a um endereço IP específico, ao mesmo tempo em que continuamos a permitir que todos os outros usuários façam login sem restrições:

    Match User ashley
      AllowUsers ashley@203.0.113.1

**Atenção:** dentro de um arquivo de configuração OpenSSH, todas as configurações sob um bloco `Match` só se aplicarão a conexões que correspondam aos critérios, independentemente da indentação ou de quebras de linha. Isso significa que você deve ter cuidado e garantir que as configurações destinadas a serem aplicadas globalmente não sejam colocadas acidentalmente dentro de um bloco `Match`. Recomenda-se colocar todos os blocos `Match` ao final do seu arquivo de configuração para ajudar a evitar isso.

Depois de finalizar sua configuração, adicione-a ao final do seu arquivo de configuração do servidor OpenSSH:

sshd\_config

    AllowUsers *@203.0.113.1

Salve e feche o arquivo, e então proceda com o teste de sintaxe da configuração:

    sudo sshd -t

Se nenhum erro for relatado, recarregue o servidor OpenSSH para aplicar sua configuração:

    sudo service sshd reload

Neste passo, você implementou uma lista de permissões de endereço IP em seu servidor OpenSSH. Em seguida, você restringirá o shell de um usuário limitando os comandos que eles estão autorizados a usar.

## Passo 3 — Restringindo o shell de um usuário

Neste passo, você verá as várias opções para restringir o shell de um usuário SSH.

Além de fornecer acesso ao shell remoto, o SSH também é ótimo para transferir arquivos e outros dados, por exemplo, via SFTP. No entanto, você nem sempre vai querer conceder acesso completo ao shell para os usuários quando eles só precisam ser capazes de realizar transferências de arquivos.

Existem várias configurações dentro do servidor OpenSSH que você pode usar para restringir o ambiente shell de usuários em particular. Por exemplo, neste tutorial, usaremos estas para criar usuários somente de SFTP.

Primeiramente, você pode usar o shell `/usr/sbin/nologin` para desativar logins interativos para certas contas de usuário, ao mesmo tempo em que você ainda permite que sessões não interativas funcionem, como transferências de arquivos, tunelamento e assim por diante.

Para criar um novo usuário com o shell do `nologin`, use o seguinte comando:

    sudo adduser --shell /usr/sbin/nologin alex

Alternativamente, você pode alterar o shell de um usuário existente para ser `nologin`:

    sudo usermod --shell /usr/sbin/nologin sammy

Se você então tentar fazer login interativamente como um desses usuários, a solicitação será rejeitada:

    sudo su alex

Isso resultará em algo semelhante à seguinte mensagem:

    Output
    This account is currently not available.

Apesar da mensagem de rejeição em logins interativos, outras ações, como as transferências de arquivos, ainda serão permitidas.

Em seguida, você deve combinar seu uso do shell `nologin` com algumas opções de configuração adicionais para restringir ainda mais as contas de usuário relevantes.

Comece abrindo o arquivo de configuração do servidor OpenSSH em seu editor de texto favorito novamente:

    sudo nano /etc/ssh/sshd_config

Existem duas opções de configuração que você pode implementar juntas para criar uma conta de usuário apenas SFTP restrita: `ForceCommand internal-sftp` e `ChrootDirectory`.

A opção `ForceCommand` dentro do servidor OpenSSH força um usuário a executar um comando específico no login. Isso pode ser útil para certas comunicações de máquina a máquina, ou para lançar à força um programa específico.

No entanto, neste caso, o comando `internal-sftp` é particularmente útil. Essa é uma função especial do servidor OpenSSH que lança um daemon básico local do SFTP que não requer nenhum arquivo de sistema de suporte ou configuração.

Isso deve ser combinado idealmente com a opção `ChrootDirectory`, que irá substituir/alterar o diretório raiz percebido para um usuário em particular, restringindo-o essencialmente a um diretório específico no sistema.

Adicione a seção de configuração a seguir ao arquivo de configuração do servidor OpenSSH para isso:

sshd\_config

    Match User alex
      ForceCommand internal-sftp
      ChrootDirectory /home/alex/

**Atenção:** como observado no Passo 2, dentro de um arquivo de configuração OpenSSH, todas as configurações sob um bloco `Match` só se aplicarão a conexões que correspondam aos critérios, independentemente da indentação ou de quebras de linha. Isso significa que você deve ter cuidado e garantir que as configurações destinadas a serem aplicadas globalmente não sejam colocadas acidentalmente dentro de um bloco `Match`. Recomenda-se colocar todos os blocos `Match` ao final do seu arquivo de configuração para ajudar a evitar isso.

Salve e feche o arquivo de configuração e então teste a configuração novamente:

    sudo sshd -t

Se não houver erros, aplique a configuração:

    sudo service sshd reload

Isso criou uma configuração robusta para o usuário `alex`, onde logins interativos estão desativados, e toda a atividade SFTP está restrita ao diretório home do usuário. Da perspectiva do usuário, a raiz do sistema, ou seja, o `/`, é seu diretório home, e eles não serão capazes de atravessar o sistema de arquivos para acessar outras áreas.

Você implementou o shell `nologin` para um usuário e então criou uma configuração para restringir o acesso SFTP a um diretório específico.

## Passo 4 — Blindagem avançada

Neste passo final, você implementará várias medidas adicionais de blindagem para tornar o acesso ao servidor SSH o mais seguro possível.

Um recurso menos conhecido do servidor OpenSSH é a capacidade de impor restrições por chave, ou seja, restrições que se aplicam apenas a chaves públicas específicas presentes no arquivo `.ssh/authorized_keys`. Isso é particularmente útil para controlar o acesso às sessões de máquina a máquina, bem como para fornecer a capacidade para usuários não sudo de controlar as restrições para sua própria conta de usuário.

Você pode aplicar a maioria dessas restrições ao nível do sistema ou do usuário, no entanto, ainda é vantajoso implementá-las no nível de chave também, para fornecer [defesa profunda](https://en.wikipedia.org/wiki/Defense_in_depth_(computing)) e uma proteção adicional contra falhas no caso de erros acidentais de configuração em todo o sistema.

**Nota:** você só pode implementar essas configurações de segurança adicionais se estiver usando a autenticação de chave pública SSH. Se você estiver usando apenas a autenticação de senha, ou tiver uma configuração mais complexa, como uma autoridade de certificação SSH, infelizmente, essas não serão utilizáveis.

Comece abrindo seu arquivo `.ssh/authorized_keys` em seu editor de texto favorito:

    nano ~/.ssh/authorized_keys

**Nota:** como essas configurações se aplicam por chave, você precisará editar cada chave individual dentro de cada arquivo de chaves `authorized_keys` individual a que você deseja que elas se apliquem, para todos os usuários em seu sistema. Normalmente, você precisará editar somente uma chave/arquivo, mas vale à pena considerar isso se você tiver um sistema multiusuário complexo.

Depois de abrir seu arquivo `authorized_keys`, você verá que cada linha contém uma chave pública SSH, que provavelmente começará com algo como `ssh-rsa AAAB...`. Mais opções de configuração podem ser adicionadas ao início da linha, e essas serão aplicadas apenas a autenticações bem sucedidas nessa chave pública específica.

As seguintes opções de restrição estão disponíveis:

* `no-agent-forwarding`: desabilitar o encaminhamento de agente SSH.
* `no-port-forwarding`: desabilitar o encaminhamento de porta SSH.
* `no-pty`: desabilitar a capacidade de alocar um tty (ou seja, iniciar um shell).
* `no-user-rc`: impedir a execução do arquivo `~/.ssh/rc`.
* `no-X11-forwarding`: desabilitar o encaminhamento de display X11.

Você pode aplicar estas medidas para desativar recursos SSH específicos para chaves específicas. Por exemplo, para desativar o encaminhamento de agente e encaminhamento X11 para uma chave, você usaria a seguinte configuração:

~/.ssh/authorized\_keys

    no-agent-forwarding,no-X11-forwarding ssh-rsa AAAB...

Por padrão, essas configurações funcionam usando uma metodologia “permitir por padrão, bloquear por exceção”; no entanto, também é possível usar “bloquear por padrão, permitir por exceção”, que é geralmente preferível para garantir a segurança.

Você pode fazer isso usando a opção `restrict`, que irá negar implicitamente todos os recursos SSH para a chave específica, exigindo que eles sejam explicitamente re-habilitados apenas quando absolutamente necessário. É possível re-habilitar recursos usando as mesmas opções de configuração descritas anteriormente neste tutorial, mas sem o prefixo `no-`.

Por exemplo, para desativar todos os recursos SSH para uma chave particular, além do encaminhamento de display X11, você pode usar a seguinte configuração:

~/.ssh/authorized\_keys

    restrict,X11-forwarding ssh-rsa AAAB...

É possível também considerar o uso da opção `command`, que é muito semelhante à opção `ForceCommand` descrita no Passo 3. Isso não fornece um benefício direto se você já estiver usando o `ForceCommand`, mas é uma boa defesa profunda tê-la funcionando, apenas no caso do arquivo de configuração principal do servidor OpenSSH ser substituído, editado e assim por diante.

Por exemplo, para forçar os usuários a se autenticarem com uma chave específica para executar um comando específico no login, adicione a seguinte configuração:

~/.ssh/authorized\_keys

    command="top" ssh-rsa AAAB...

**Atenção:** a opção de configuração `command` atua puramente como um método de defesa profunda, e não deve ser usada apenas para restringir as atividades de um usuário SSH, pois existem outras maneiras possíveis de substituí-la ou contorná-la dependendo do seu ambiente. Em vez disso, você deve usar a configuração em conjunto com os outros controles descritos neste artigo.

Por fim, para usar melhor as restrições por chave para o usuário SFTP que você criou no Passo 3, use a seguinte configuração:

~/.ssh/authorized\_keys

    restrict,command="false" ssh-rsa AAAB...

A opção `restrict` desativará todo o acesso interativo, e a opção `command="false"` atua como uma segunda linha de defesa, caso a opção `ForceCommand` ou o shell `nologin` venham a falhar.

Salve e feche o arquivo para aplicar a configuração. Isso irá produzir efeito imediatamente para todos os novos logins, portanto, você não precisa recarregar o OpenSSH manualmente.

Neste passo final, você implementou algumas medidas adicionais avançadas de blindagem para o servidor OpenSSH usando as opções personalizadas dentro de seu(s) arquivo(s) `.ssh/authorized_keys`.

## Conclusão

Neste artigo, você revisou a configuração do servidor OpenSSH e implementou várias medidas de blindagem para ajudar a protegê-lo.

Isso terá reduzido a superfície geral de ataque do servidor desativando recursos não usados e fechando o acesso de usuários específicos.

Revise as [páginas de manual para o servidor OpenSSH](https://linux.die.net/man/8/sshd) e seu [arquivo de configuração](https://linux.die.net/man/5/sshd_config) associado, para identificar quaisquer possíveis novos ajustes que você queira fazer.

