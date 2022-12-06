include:
  - users.sudo

{% for name, user in pillar.get('users', {}).items() %}
{% if user == None %}
{% set user = {} %}
{% endif %}
{% set home = user.get('home', "/home/%s" % name) %}

{% for group in user.get('groups', []) %}
{{ group }}_group:
  group:
    - name: {{ group }}
    - present
{% endfor %}

{{ name }}_user:
  file.directory:
    - name: {{ home }}
    - user: {{ name }}
    - group: {{ name }}
    - mode: 0755
    - require:
      - user: {{ name }}
      - group: {{ name }}
  group.present:
    - name: {{ name }}
  user.present:
    - name: {{ name }}
    - home: {{ home }}
    - shell: {{ pillar.get('shell', '/bin/bash') }}
    {% if 'uid' in user -%}
    - uid: {{ user['uid'] }}
    {% endif %}
    - gid_from_name: True
    {% if 'fullname' in user %}
    - fullname: {{ user['fullname'] }}
    {% endif %}
    - groups:
        - {{ name }}
      {% for group in user.get('groups', []) %}
        - {{ group }}_group
      {% endfor %}
    - require:
        - group: {{ name }}_user
      {% for group in user.get('groups', []) %}
        - group: {{ group }}_group
      {% endfor %}

  {% if 'ssh_auth' in user %}
  {% for auth in user['ssh_auth'] %}
ssh_auth_{{ name }}_{{ loop.index0 }}:
  ssh_auth.present:
    - user: {{ name }}
    - name: {{ auth }}
    - require:
        - file: {{ name }}_user
        - user: {{ name }}_user
{% endfor %}
{% endif %}

{% if 'sudouser' in user %}
sudoer-{{ name }}:
    file.append:
        - name: /etc/sudoers
        - text:
          - "{{ name }}    ALL=(ALL)  NOPASSWD: ALL"
        - require:
          - file: sudoer-defaults

{% endif %}

{% endfor %}

{% for user in pillar.get('absent_users', []) %}
{{ user }}:
  user.absent
{% endfor %}
