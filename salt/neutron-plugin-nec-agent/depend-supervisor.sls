# vi: set ft=yaml.jinja :

{% set psls = sls.split('.')[0] %}

{% if salt['config.get']('virtual_subtype') == 'Docker' %}

include:
  -  neutron-plugin-nec-agent
  -  supervisor

extend:
  neutron-plugin-nec-agent:
    supervisord.running:
      - require:
        - file:   /var/run/neutron
      - watch:
        - pkg:     neutron-plugin-nec-agent
        - service: supervisor
#       - file:   /etc/neutron/api-paste.ini
        - file:   /etc/neutron/fwaas_driver.ini
        - file:   /etc/neutron/l3_agent.ini
        - file:   /etc/neutron/neutron.conf
#       - file:   /etc/neutron/policy.json
        - file:   /etc/neutron/vpn_agent.ini
        - file:   /etc/neutron/plugins/nec/nec.ini

/etc/supervisor/conf.d/{{ psls }}.conf:
  file.managed:
    - template:    jinja
    - source:      salt://{{ psls }}/etc/supervisor/conf.d/{{ psls }}.conf
    - user:        root
    - group:       root
    - mode:       '0644'
    - require:
      - file:     /usr/bin/supervisord
    - require_in:
      - service:   supervisor
    - watch_in:
      - cmd:       supervisorctl update &

{% endif %}
