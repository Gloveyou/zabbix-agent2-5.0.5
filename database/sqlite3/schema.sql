CREATE TABLE users (
	userid                   bigint                                    NOT NULL,
	alias                    varchar(100)    DEFAULT ''                NOT NULL,
	name                     varchar(100)    DEFAULT ''                NOT NULL,
	surname                  varchar(100)    DEFAULT ''                NOT NULL,
	passwd                   varchar(60)     DEFAULT ''                NOT NULL,
	url                      varchar(255)    DEFAULT ''                NOT NULL,
	autologin                integer         DEFAULT '0'               NOT NULL,
	autologout               varchar(32)     DEFAULT '15m'             NOT NULL,
	lang                     varchar(5)      DEFAULT 'en_GB'           NOT NULL,
	refresh                  varchar(32)     DEFAULT '30s'             NOT NULL,
	type                     integer         DEFAULT '1'               NOT NULL,
	theme                    varchar(128)    DEFAULT 'default'         NOT NULL,
	attempt_failed           integer         DEFAULT 0                 NOT NULL,
	attempt_ip               varchar(39)     DEFAULT ''                NOT NULL,
	attempt_clock            integer         DEFAULT 0                 NOT NULL,
	rows_per_page            integer         DEFAULT 50                NOT NULL,
	PRIMARY KEY (userid)
);
CREATE UNIQUE INDEX users_1 ON users (alias);
CREATE TABLE maintenances (
	maintenanceid            bigint                                    NOT NULL,
	name                     varchar(128)    DEFAULT ''                NOT NULL,
	maintenance_type         integer         DEFAULT '0'               NOT NULL,
	description              text            DEFAULT ''                NOT NULL,
	active_since             integer         DEFAULT '0'               NOT NULL,
	active_till              integer         DEFAULT '0'               NOT NULL,
	tags_evaltype            integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (maintenanceid)
);
CREATE INDEX maintenances_1 ON maintenances (active_since,active_till);
CREATE UNIQUE INDEX maintenances_2 ON maintenances (name);
CREATE TABLE hosts (
	hostid                   bigint                                    NOT NULL,
	proxy_hostid             bigint                                    NULL REFERENCES hosts (hostid),
	host                     varchar(128)    DEFAULT ''                NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	disable_until            integer         DEFAULT '0'               NOT NULL,
	error                    varchar(2048)   DEFAULT ''                NOT NULL,
	available                integer         DEFAULT '0'               NOT NULL,
	errors_from              integer         DEFAULT '0'               NOT NULL,
	lastaccess               integer         DEFAULT '0'               NOT NULL,
	ipmi_authtype            integer         DEFAULT '-1'              NOT NULL,
	ipmi_privilege           integer         DEFAULT '2'               NOT NULL,
	ipmi_username            varchar(16)     DEFAULT ''                NOT NULL,
	ipmi_password            varchar(20)     DEFAULT ''                NOT NULL,
	ipmi_disable_until       integer         DEFAULT '0'               NOT NULL,
	ipmi_available           integer         DEFAULT '0'               NOT NULL,
	snmp_disable_until       integer         DEFAULT '0'               NOT NULL,
	snmp_available           integer         DEFAULT '0'               NOT NULL,
	maintenanceid            bigint                                    NULL REFERENCES maintenances (maintenanceid),
	maintenance_status       integer         DEFAULT '0'               NOT NULL,
	maintenance_type         integer         DEFAULT '0'               NOT NULL,
	maintenance_from         integer         DEFAULT '0'               NOT NULL,
	ipmi_errors_from         integer         DEFAULT '0'               NOT NULL,
	snmp_errors_from         integer         DEFAULT '0'               NOT NULL,
	ipmi_error               varchar(2048)   DEFAULT ''                NOT NULL,
	snmp_error               varchar(2048)   DEFAULT ''                NOT NULL,
	jmx_disable_until        integer         DEFAULT '0'               NOT NULL,
	jmx_available            integer         DEFAULT '0'               NOT NULL,
	jmx_errors_from          integer         DEFAULT '0'               NOT NULL,
	jmx_error                varchar(2048)   DEFAULT ''                NOT NULL,
	name                     varchar(128)    DEFAULT ''                NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	templateid               bigint                                    NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	description              text            DEFAULT ''                NOT NULL,
	tls_connect              integer         DEFAULT '1'               NOT NULL,
	tls_accept               integer         DEFAULT '1'               NOT NULL,
	tls_issuer               varchar(1024)   DEFAULT ''                NOT NULL,
	tls_subject              varchar(1024)   DEFAULT ''                NOT NULL,
	tls_psk_identity         varchar(128)    DEFAULT ''                NOT NULL,
	tls_psk                  varchar(512)    DEFAULT ''                NOT NULL,
	proxy_address            varchar(255)    DEFAULT ''                NOT NULL,
	auto_compress            integer         DEFAULT '1'               NOT NULL,
	discover                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (hostid)
);
CREATE INDEX hosts_1 ON hosts (host);
CREATE INDEX hosts_2 ON hosts (status);
CREATE INDEX hosts_3 ON hosts (proxy_hostid);
CREATE INDEX hosts_4 ON hosts (name);
CREATE INDEX hosts_5 ON hosts (maintenanceid);
CREATE TABLE hstgrp (
	groupid                  bigint                                    NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	internal                 integer         DEFAULT '0'               NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (groupid)
);
CREATE INDEX hstgrp_1 ON hstgrp (name);
CREATE TABLE group_prototype (
	group_prototypeid        bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	groupid                  bigint                                    NULL REFERENCES hstgrp (groupid),
	templateid               bigint                                    NULL REFERENCES group_prototype (group_prototypeid) ON DELETE CASCADE,
	PRIMARY KEY (group_prototypeid)
);
CREATE INDEX group_prototype_1 ON group_prototype (hostid);
CREATE TABLE group_discovery (
	groupid                  bigint                                    NOT NULL REFERENCES hstgrp (groupid) ON DELETE CASCADE,
	parent_group_prototypeid bigint                                    NOT NULL REFERENCES group_prototype (group_prototypeid),
	name                     varchar(64)     DEFAULT ''                NOT NULL,
	lastcheck                integer         DEFAULT '0'               NOT NULL,
	ts_delete                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (groupid)
);
CREATE TABLE screens (
	screenid                 bigint                                    NOT NULL,
	name                     varchar(255)                              NOT NULL,
	hsize                    integer         DEFAULT '1'               NOT NULL,
	vsize                    integer         DEFAULT '1'               NOT NULL,
	templateid               bigint                                    NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	userid                   bigint                                    NULL REFERENCES users (userid),
	private                  integer         DEFAULT '1'               NOT NULL,
	PRIMARY KEY (screenid)
);
CREATE INDEX screens_1 ON screens (templateid);
CREATE TABLE screens_items (
	screenitemid             bigint                                    NOT NULL,
	screenid                 bigint                                    NOT NULL REFERENCES screens (screenid) ON DELETE CASCADE,
	resourcetype             integer         DEFAULT '0'               NOT NULL,
	resourceid               bigint          DEFAULT '0'               NOT NULL,
	width                    integer         DEFAULT '320'             NOT NULL,
	height                   integer         DEFAULT '200'             NOT NULL,
	x                        integer         DEFAULT '0'               NOT NULL,
	y                        integer         DEFAULT '0'               NOT NULL,
	colspan                  integer         DEFAULT '1'               NOT NULL,
	rowspan                  integer         DEFAULT '1'               NOT NULL,
	elements                 integer         DEFAULT '25'              NOT NULL,
	valign                   integer         DEFAULT '0'               NOT NULL,
	halign                   integer         DEFAULT '0'               NOT NULL,
	style                    integer         DEFAULT '0'               NOT NULL,
	url                      varchar(255)    DEFAULT ''                NOT NULL,
	dynamic                  integer         DEFAULT '0'               NOT NULL,
	sort_triggers            integer         DEFAULT '0'               NOT NULL,
	application              varchar(255)    DEFAULT ''                NOT NULL,
	max_columns              integer         DEFAULT '3'               NOT NULL,
	PRIMARY KEY (screenitemid)
);
CREATE INDEX screens_items_1 ON screens_items (screenid);
CREATE TABLE screen_user (
	screenuserid             bigint                                    NOT NULL,
	screenid                 bigint                                    NOT NULL REFERENCES screens (screenid) ON DELETE CASCADE,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (screenuserid)
);
CREATE UNIQUE INDEX screen_user_1 ON screen_user (screenid,userid);
CREATE TABLE screen_usrgrp (
	screenusrgrpid           bigint                                    NOT NULL,
	screenid                 bigint                                    NOT NULL REFERENCES screens (screenid) ON DELETE CASCADE,
	usrgrpid                 bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (screenusrgrpid)
);
CREATE UNIQUE INDEX screen_usrgrp_1 ON screen_usrgrp (screenid,usrgrpid);
CREATE TABLE slideshows (
	slideshowid              bigint                                    NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	delay                    varchar(32)     DEFAULT '30s'             NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid),
	private                  integer         DEFAULT '1'               NOT NULL,
	PRIMARY KEY (slideshowid)
);
CREATE UNIQUE INDEX slideshows_1 ON slideshows (name);
CREATE TABLE slideshow_user (
	slideshowuserid          bigint                                    NOT NULL,
	slideshowid              bigint                                    NOT NULL REFERENCES slideshows (slideshowid) ON DELETE CASCADE,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (slideshowuserid)
);
CREATE UNIQUE INDEX slideshow_user_1 ON slideshow_user (slideshowid,userid);
CREATE TABLE slideshow_usrgrp (
	slideshowusrgrpid        bigint                                    NOT NULL,
	slideshowid              bigint                                    NOT NULL REFERENCES slideshows (slideshowid) ON DELETE CASCADE,
	usrgrpid                 bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (slideshowusrgrpid)
);
CREATE UNIQUE INDEX slideshow_usrgrp_1 ON slideshow_usrgrp (slideshowid,usrgrpid);
CREATE TABLE slides (
	slideid                  bigint                                    NOT NULL,
	slideshowid              bigint                                    NOT NULL REFERENCES slideshows (slideshowid) ON DELETE CASCADE,
	screenid                 bigint                                    NOT NULL REFERENCES screens (screenid) ON DELETE CASCADE,
	step                     integer         DEFAULT '0'               NOT NULL,
	delay                    varchar(32)     DEFAULT '0'               NOT NULL,
	PRIMARY KEY (slideid)
);
CREATE INDEX slides_1 ON slides (slideshowid);
CREATE INDEX slides_2 ON slides (screenid);
CREATE TABLE drules (
	druleid                  bigint                                    NOT NULL,
	proxy_hostid             bigint                                    NULL REFERENCES hosts (hostid),
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	iprange                  varchar(2048)   DEFAULT ''                NOT NULL,
	delay                    varchar(255)    DEFAULT '1h'              NOT NULL,
	nextcheck                integer         DEFAULT '0'               NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (druleid)
);
CREATE INDEX drules_1 ON drules (proxy_hostid);
CREATE UNIQUE INDEX drules_2 ON drules (name);
CREATE TABLE dchecks (
	dcheckid                 bigint                                    NOT NULL,
	druleid                  bigint                                    NOT NULL REFERENCES drules (druleid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	key_                     varchar(2048)   DEFAULT ''                NOT NULL,
	snmp_community           varchar(255)    DEFAULT ''                NOT NULL,
	ports                    varchar(255)    DEFAULT '0'               NOT NULL,
	snmpv3_securityname      varchar(64)     DEFAULT ''                NOT NULL,
	snmpv3_securitylevel     integer         DEFAULT '0'               NOT NULL,
	snmpv3_authpassphrase    varchar(64)     DEFAULT ''                NOT NULL,
	snmpv3_privpassphrase    varchar(64)     DEFAULT ''                NOT NULL,
	uniq                     integer         DEFAULT '0'               NOT NULL,
	snmpv3_authprotocol      integer         DEFAULT '0'               NOT NULL,
	snmpv3_privprotocol      integer         DEFAULT '0'               NOT NULL,
	snmpv3_contextname       varchar(255)    DEFAULT ''                NOT NULL,
	host_source              integer         DEFAULT '1'               NOT NULL,
	name_source              integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (dcheckid)
);
CREATE INDEX dchecks_1 ON dchecks (druleid,host_source,name_source);
CREATE TABLE applications (
	applicationid            bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (applicationid)
);
CREATE UNIQUE INDEX applications_2 ON applications (hostid,name);
CREATE TABLE httptest (
	httptestid               bigint                                    NOT NULL,
	name                     varchar(64)     DEFAULT ''                NOT NULL,
	applicationid            bigint                                    NULL REFERENCES applications (applicationid),
	nextcheck                integer         DEFAULT '0'               NOT NULL,
	delay                    varchar(255)    DEFAULT '1m'              NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	agent                    varchar(255)    DEFAULT 'Zabbix'          NOT NULL,
	authentication           integer         DEFAULT '0'               NOT NULL,
	http_user                varchar(64)     DEFAULT ''                NOT NULL,
	http_password            varchar(64)     DEFAULT ''                NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	templateid               bigint                                    NULL REFERENCES httptest (httptestid) ON DELETE CASCADE,
	http_proxy               varchar(255)    DEFAULT ''                NOT NULL,
	retries                  integer         DEFAULT '1'               NOT NULL,
	ssl_cert_file            varchar(255)    DEFAULT ''                NOT NULL,
	ssl_key_file             varchar(255)    DEFAULT ''                NOT NULL,
	ssl_key_password         varchar(64)     DEFAULT ''                NOT NULL,
	verify_peer              integer         DEFAULT '0'               NOT NULL,
	verify_host              integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (httptestid)
);
CREATE INDEX httptest_1 ON httptest (applicationid);
CREATE UNIQUE INDEX httptest_2 ON httptest (hostid,name);
CREATE INDEX httptest_3 ON httptest (status);
CREATE INDEX httptest_4 ON httptest (templateid);
CREATE TABLE httpstep (
	httpstepid               bigint                                    NOT NULL,
	httptestid               bigint                                    NOT NULL REFERENCES httptest (httptestid) ON DELETE CASCADE,
	name                     varchar(64)     DEFAULT ''                NOT NULL,
	no                       integer         DEFAULT '0'               NOT NULL,
	url                      varchar(2048)   DEFAULT ''                NOT NULL,
	timeout                  varchar(255)    DEFAULT '15s'             NOT NULL,
	posts                    text            DEFAULT ''                NOT NULL,
	required                 varchar(255)    DEFAULT ''                NOT NULL,
	status_codes             varchar(255)    DEFAULT ''                NOT NULL,
	follow_redirects         integer         DEFAULT '1'               NOT NULL,
	retrieve_mode            integer         DEFAULT '0'               NOT NULL,
	post_type                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (httpstepid)
);
CREATE INDEX httpstep_1 ON httpstep (httptestid);
CREATE TABLE interface (
	interfaceid              bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	main                     integer         DEFAULT '0'               NOT NULL,
	type                     integer         DEFAULT '1'               NOT NULL,
	useip                    integer         DEFAULT '1'               NOT NULL,
	ip                       varchar(64)     DEFAULT '127.0.0.1'       NOT NULL,
	dns                      varchar(255)    DEFAULT ''                NOT NULL,
	port                     varchar(64)     DEFAULT '10050'           NOT NULL,
	PRIMARY KEY (interfaceid)
);
CREATE INDEX interface_1 ON interface (hostid,type);
CREATE INDEX interface_2 ON interface (ip,dns);
CREATE TABLE valuemaps (
	valuemapid               bigint                                    NOT NULL,
	name                     varchar(64)     DEFAULT ''                NOT NULL,
	PRIMARY KEY (valuemapid)
);
CREATE UNIQUE INDEX valuemaps_1 ON valuemaps (name);
CREATE TABLE items (
	itemid                   bigint                                    NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	snmp_oid                 varchar(512)    DEFAULT ''                NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	key_                     varchar(2048)   DEFAULT ''                NOT NULL,
	delay                    varchar(1024)   DEFAULT '0'               NOT NULL,
	history                  varchar(255)    DEFAULT '90d'             NOT NULL,
	trends                   varchar(255)    DEFAULT '365d'            NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	value_type               integer         DEFAULT '0'               NOT NULL,
	trapper_hosts            varchar(255)    DEFAULT ''                NOT NULL,
	units                    varchar(255)    DEFAULT ''                NOT NULL,
	formula                  varchar(255)    DEFAULT ''                NOT NULL,
	logtimefmt               varchar(64)     DEFAULT ''                NOT NULL,
	templateid               bigint                                    NULL REFERENCES items (itemid) ON DELETE CASCADE,
	valuemapid               bigint                                    NULL REFERENCES valuemaps (valuemapid),
	params                   text            DEFAULT ''                NOT NULL,
	ipmi_sensor              varchar(128)    DEFAULT ''                NOT NULL,
	authtype                 integer         DEFAULT '0'               NOT NULL,
	username                 varchar(64)     DEFAULT ''                NOT NULL,
	password                 varchar(64)     DEFAULT ''                NOT NULL,
	publickey                varchar(64)     DEFAULT ''                NOT NULL,
	privatekey               varchar(64)     DEFAULT ''                NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	interfaceid              bigint                                    NULL REFERENCES interface (interfaceid),
	description              text            DEFAULT ''                NOT NULL,
	inventory_link           integer         DEFAULT '0'               NOT NULL,
	lifetime                 varchar(255)    DEFAULT '30d'             NOT NULL,
	evaltype                 integer         DEFAULT '0'               NOT NULL,
	jmx_endpoint             varchar(255)    DEFAULT ''                NOT NULL,
	master_itemid            bigint                                    NULL REFERENCES items (itemid) ON DELETE CASCADE,
	timeout                  varchar(255)    DEFAULT '3s'              NOT NULL,
	url                      varchar(2048)   DEFAULT ''                NOT NULL,
	query_fields             varchar(2048)   DEFAULT ''                NOT NULL,
	posts                    text            DEFAULT ''                NOT NULL,
	status_codes             varchar(255)    DEFAULT '200'             NOT NULL,
	follow_redirects         integer         DEFAULT '1'               NOT NULL,
	post_type                integer         DEFAULT '0'               NOT NULL,
	http_proxy               varchar(255)    DEFAULT ''                NOT NULL,
	headers                  text            DEFAULT ''                NOT NULL,
	retrieve_mode            integer         DEFAULT '0'               NOT NULL,
	request_method           integer         DEFAULT '0'               NOT NULL,
	output_format            integer         DEFAULT '0'               NOT NULL,
	ssl_cert_file            varchar(255)    DEFAULT ''                NOT NULL,
	ssl_key_file             varchar(255)    DEFAULT ''                NOT NULL,
	ssl_key_password         varchar(64)     DEFAULT ''                NOT NULL,
	verify_peer              integer         DEFAULT '0'               NOT NULL,
	verify_host              integer         DEFAULT '0'               NOT NULL,
	allow_traps              integer         DEFAULT '0'               NOT NULL,
	discover                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (itemid)
);
CREATE INDEX items_1 ON items (hostid,key_);
CREATE INDEX items_3 ON items (status);
CREATE INDEX items_4 ON items (templateid);
CREATE INDEX items_5 ON items (valuemapid);
CREATE INDEX items_6 ON items (interfaceid);
CREATE INDEX items_7 ON items (master_itemid);
CREATE TABLE httpstepitem (
	httpstepitemid           bigint                                    NOT NULL,
	httpstepid               bigint                                    NOT NULL REFERENCES httpstep (httpstepid) ON DELETE CASCADE,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (httpstepitemid)
);
CREATE UNIQUE INDEX httpstepitem_1 ON httpstepitem (httpstepid,itemid);
CREATE INDEX httpstepitem_2 ON httpstepitem (itemid);
CREATE TABLE httptestitem (
	httptestitemid           bigint                                    NOT NULL,
	httptestid               bigint                                    NOT NULL REFERENCES httptest (httptestid) ON DELETE CASCADE,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (httptestitemid)
);
CREATE UNIQUE INDEX httptestitem_1 ON httptestitem (httptestid,itemid);
CREATE INDEX httptestitem_2 ON httptestitem (itemid);
CREATE TABLE media_type (
	mediatypeid              bigint                                    NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	name                     varchar(100)    DEFAULT ''                NOT NULL,
	smtp_server              varchar(255)    DEFAULT ''                NOT NULL,
	smtp_helo                varchar(255)    DEFAULT ''                NOT NULL,
	smtp_email               varchar(255)    DEFAULT ''                NOT NULL,
	exec_path                varchar(255)    DEFAULT ''                NOT NULL,
	gsm_modem                varchar(255)    DEFAULT ''                NOT NULL,
	username                 varchar(255)    DEFAULT ''                NOT NULL,
	passwd                   varchar(255)    DEFAULT ''                NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	smtp_port                integer         DEFAULT '25'              NOT NULL,
	smtp_security            integer         DEFAULT '0'               NOT NULL,
	smtp_verify_peer         integer         DEFAULT '0'               NOT NULL,
	smtp_verify_host         integer         DEFAULT '0'               NOT NULL,
	smtp_authentication      integer         DEFAULT '0'               NOT NULL,
	exec_params              varchar(255)    DEFAULT ''                NOT NULL,
	maxsessions              integer         DEFAULT '1'               NOT NULL,
	maxattempts              integer         DEFAULT '3'               NOT NULL,
	attempt_interval         varchar(32)     DEFAULT '10s'             NOT NULL,
	content_type             integer         DEFAULT '1'               NOT NULL,
	script                   text            DEFAULT ''                NOT NULL,
	timeout                  varchar(32)     DEFAULT '30s'             NOT NULL,
	process_tags             integer         DEFAULT '0'               NOT NULL,
	show_event_menu          integer         DEFAULT '0'               NOT NULL,
	event_menu_url           varchar(2048)   DEFAULT ''                NOT NULL,
	event_menu_name          varchar(255)    DEFAULT ''                NOT NULL,
	description              text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (mediatypeid)
);
CREATE UNIQUE INDEX media_type_1 ON media_type (name);
CREATE TABLE media_type_param (
	mediatype_paramid        bigint                                    NOT NULL,
	mediatypeid              bigint                                    NOT NULL REFERENCES media_type (mediatypeid) ON DELETE CASCADE,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(2048)   DEFAULT ''                NOT NULL,
	PRIMARY KEY (mediatype_paramid)
);
CREATE INDEX media_type_param_1 ON media_type_param (mediatypeid);
CREATE TABLE media_type_message (
	mediatype_messageid      bigint                                    NOT NULL,
	mediatypeid              bigint                                    NOT NULL REFERENCES media_type (mediatypeid) ON DELETE CASCADE,
	eventsource              integer                                   NOT NULL,
	recovery                 integer                                   NOT NULL,
	subject                  varchar(255)    DEFAULT ''                NOT NULL,
	message                  text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (mediatype_messageid)
);
CREATE UNIQUE INDEX media_type_message_1 ON media_type_message (mediatypeid,eventsource,recovery);
CREATE TABLE usrgrp (
	usrgrpid                 bigint                                    NOT NULL,
	name                     varchar(64)     DEFAULT ''                NOT NULL,
	gui_access               integer         DEFAULT '0'               NOT NULL,
	users_status             integer         DEFAULT '0'               NOT NULL,
	debug_mode               integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (usrgrpid)
);
CREATE UNIQUE INDEX usrgrp_1 ON usrgrp (name);
CREATE TABLE users_groups (
	id                       bigint                                    NOT NULL,
	usrgrpid                 bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid) ON DELETE CASCADE,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	PRIMARY KEY (id)
);
CREATE UNIQUE INDEX users_groups_1 ON users_groups (usrgrpid,userid);
CREATE INDEX users_groups_2 ON users_groups (userid);
CREATE TABLE scripts (
	scriptid                 bigint                                    NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	command                  varchar(255)    DEFAULT ''                NOT NULL,
	host_access              integer         DEFAULT '2'               NOT NULL,
	usrgrpid                 bigint                                    NULL REFERENCES usrgrp (usrgrpid),
	groupid                  bigint                                    NULL REFERENCES hstgrp (groupid),
	description              text            DEFAULT ''                NOT NULL,
	confirmation             varchar(255)    DEFAULT ''                NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	execute_on               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (scriptid)
);
CREATE INDEX scripts_1 ON scripts (usrgrpid);
CREATE INDEX scripts_2 ON scripts (groupid);
CREATE UNIQUE INDEX scripts_3 ON scripts (name);
CREATE TABLE actions (
	actionid                 bigint                                    NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	eventsource              integer         DEFAULT '0'               NOT NULL,
	evaltype                 integer         DEFAULT '0'               NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	esc_period               varchar(255)    DEFAULT '1h'              NOT NULL,
	formula                  varchar(255)    DEFAULT ''                NOT NULL,
	pause_suppressed         integer         DEFAULT '1'               NOT NULL,
	PRIMARY KEY (actionid)
);
CREATE INDEX actions_1 ON actions (eventsource,status);
CREATE UNIQUE INDEX actions_2 ON actions (name);
CREATE TABLE operations (
	operationid              bigint                                    NOT NULL,
	actionid                 bigint                                    NOT NULL REFERENCES actions (actionid) ON DELETE CASCADE,
	operationtype            integer         DEFAULT '0'               NOT NULL,
	esc_period               varchar(255)    DEFAULT '0'               NOT NULL,
	esc_step_from            integer         DEFAULT '1'               NOT NULL,
	esc_step_to              integer         DEFAULT '1'               NOT NULL,
	evaltype                 integer         DEFAULT '0'               NOT NULL,
	recovery                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (operationid)
);
CREATE INDEX operations_1 ON operations (actionid);
CREATE TABLE opmessage (
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	default_msg              integer         DEFAULT '1'               NOT NULL,
	subject                  varchar(255)    DEFAULT ''                NOT NULL,
	message                  text            DEFAULT ''                NOT NULL,
	mediatypeid              bigint                                    NULL REFERENCES media_type (mediatypeid),
	PRIMARY KEY (operationid)
);
CREATE INDEX opmessage_1 ON opmessage (mediatypeid);
CREATE TABLE opmessage_grp (
	opmessage_grpid          bigint                                    NOT NULL,
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	usrgrpid                 bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid),
	PRIMARY KEY (opmessage_grpid)
);
CREATE UNIQUE INDEX opmessage_grp_1 ON opmessage_grp (operationid,usrgrpid);
CREATE INDEX opmessage_grp_2 ON opmessage_grp (usrgrpid);
CREATE TABLE opmessage_usr (
	opmessage_usrid          bigint                                    NOT NULL,
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	userid                   bigint                                    NOT NULL REFERENCES users (userid),
	PRIMARY KEY (opmessage_usrid)
);
CREATE UNIQUE INDEX opmessage_usr_1 ON opmessage_usr (operationid,userid);
CREATE INDEX opmessage_usr_2 ON opmessage_usr (userid);
CREATE TABLE opcommand (
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	scriptid                 bigint                                    NULL REFERENCES scripts (scriptid),
	execute_on               integer         DEFAULT '0'               NOT NULL,
	port                     varchar(64)     DEFAULT ''                NOT NULL,
	authtype                 integer         DEFAULT '0'               NOT NULL,
	username                 varchar(64)     DEFAULT ''                NOT NULL,
	password                 varchar(64)     DEFAULT ''                NOT NULL,
	publickey                varchar(64)     DEFAULT ''                NOT NULL,
	privatekey               varchar(64)     DEFAULT ''                NOT NULL,
	command                  text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (operationid)
);
CREATE INDEX opcommand_1 ON opcommand (scriptid);
CREATE TABLE opcommand_hst (
	opcommand_hstid          bigint                                    NOT NULL,
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	hostid                   bigint                                    NULL REFERENCES hosts (hostid),
	PRIMARY KEY (opcommand_hstid)
);
CREATE INDEX opcommand_hst_1 ON opcommand_hst (operationid);
CREATE INDEX opcommand_hst_2 ON opcommand_hst (hostid);
CREATE TABLE opcommand_grp (
	opcommand_grpid          bigint                                    NOT NULL,
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	groupid                  bigint                                    NOT NULL REFERENCES hstgrp (groupid),
	PRIMARY KEY (opcommand_grpid)
);
CREATE INDEX opcommand_grp_1 ON opcommand_grp (operationid);
CREATE INDEX opcommand_grp_2 ON opcommand_grp (groupid);
CREATE TABLE opgroup (
	opgroupid                bigint                                    NOT NULL,
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	groupid                  bigint                                    NOT NULL REFERENCES hstgrp (groupid),
	PRIMARY KEY (opgroupid)
);
CREATE UNIQUE INDEX opgroup_1 ON opgroup (operationid,groupid);
CREATE INDEX opgroup_2 ON opgroup (groupid);
CREATE TABLE optemplate (
	optemplateid             bigint                                    NOT NULL,
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	templateid               bigint                                    NOT NULL REFERENCES hosts (hostid),
	PRIMARY KEY (optemplateid)
);
CREATE UNIQUE INDEX optemplate_1 ON optemplate (operationid,templateid);
CREATE INDEX optemplate_2 ON optemplate (templateid);
CREATE TABLE opconditions (
	opconditionid            bigint                                    NOT NULL,
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	conditiontype            integer         DEFAULT '0'               NOT NULL,
	operator                 integer         DEFAULT '0'               NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (opconditionid)
);
CREATE INDEX opconditions_1 ON opconditions (operationid);
CREATE TABLE conditions (
	conditionid              bigint                                    NOT NULL,
	actionid                 bigint                                    NOT NULL REFERENCES actions (actionid) ON DELETE CASCADE,
	conditiontype            integer         DEFAULT '0'               NOT NULL,
	operator                 integer         DEFAULT '0'               NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	value2                   varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (conditionid)
);
CREATE INDEX conditions_1 ON conditions (actionid);
CREATE TABLE config (
	configid                 bigint                                    NOT NULL,
	refresh_unsupported      varchar(32)     DEFAULT '10m'             NOT NULL,
	work_period              varchar(255)    DEFAULT '1-5,09:00-18:00' NOT NULL,
	alert_usrgrpid           bigint                                    NULL REFERENCES usrgrp (usrgrpid),
	default_theme            varchar(128)    DEFAULT 'blue-theme'      NOT NULL,
	authentication_type      integer         DEFAULT '0'               NOT NULL,
	ldap_host                varchar(255)    DEFAULT ''                NOT NULL,
	ldap_port                integer         DEFAULT 389               NOT NULL,
	ldap_base_dn             varchar(255)    DEFAULT ''                NOT NULL,
	ldap_bind_dn             varchar(255)    DEFAULT ''                NOT NULL,
	ldap_bind_password       varchar(128)    DEFAULT ''                NOT NULL,
	ldap_search_attribute    varchar(128)    DEFAULT ''                NOT NULL,
	discovery_groupid        bigint                                    NOT NULL REFERENCES hstgrp (groupid),
	max_in_table             integer         DEFAULT '50'              NOT NULL,
	search_limit             integer         DEFAULT '1000'            NOT NULL,
	severity_color_0         varchar(6)      DEFAULT '97AAB3'          NOT NULL,
	severity_color_1         varchar(6)      DEFAULT '7499FF'          NOT NULL,
	severity_color_2         varchar(6)      DEFAULT 'FFC859'          NOT NULL,
	severity_color_3         varchar(6)      DEFAULT 'FFA059'          NOT NULL,
	severity_color_4         varchar(6)      DEFAULT 'E97659'          NOT NULL,
	severity_color_5         varchar(6)      DEFAULT 'E45959'          NOT NULL,
	severity_name_0          varchar(32)     DEFAULT 'Not classified'  NOT NULL,
	severity_name_1          varchar(32)     DEFAULT 'Information'     NOT NULL,
	severity_name_2          varchar(32)     DEFAULT 'Warning'         NOT NULL,
	severity_name_3          varchar(32)     DEFAULT 'Average'         NOT NULL,
	severity_name_4          varchar(32)     DEFAULT 'High'            NOT NULL,
	severity_name_5          varchar(32)     DEFAULT 'Disaster'        NOT NULL,
	ok_period                varchar(32)     DEFAULT '5m'              NOT NULL,
	blink_period             varchar(32)     DEFAULT '2m'              NOT NULL,
	problem_unack_color      varchar(6)      DEFAULT 'CC0000'          NOT NULL,
	problem_ack_color        varchar(6)      DEFAULT 'CC0000'          NOT NULL,
	ok_unack_color           varchar(6)      DEFAULT '009900'          NOT NULL,
	ok_ack_color             varchar(6)      DEFAULT '009900'          NOT NULL,
	problem_unack_style      integer         DEFAULT '1'               NOT NULL,
	problem_ack_style        integer         DEFAULT '1'               NOT NULL,
	ok_unack_style           integer         DEFAULT '1'               NOT NULL,
	ok_ack_style             integer         DEFAULT '1'               NOT NULL,
	snmptrap_logging         integer         DEFAULT '1'               NOT NULL,
	server_check_interval    integer         DEFAULT '10'              NOT NULL,
	hk_events_mode           integer         DEFAULT '1'               NOT NULL,
	hk_events_trigger        varchar(32)     DEFAULT '365d'            NOT NULL,
	hk_events_internal       varchar(32)     DEFAULT '1d'              NOT NULL,
	hk_events_discovery      varchar(32)     DEFAULT '1d'              NOT NULL,
	hk_events_autoreg        varchar(32)     DEFAULT '1d'              NOT NULL,
	hk_services_mode         integer         DEFAULT '1'               NOT NULL,
	hk_services              varchar(32)     DEFAULT '365d'            NOT NULL,
	hk_audit_mode            integer         DEFAULT '1'               NOT NULL,
	hk_audit                 varchar(32)     DEFAULT '365d'            NOT NULL,
	hk_sessions_mode         integer         DEFAULT '1'               NOT NULL,
	hk_sessions              varchar(32)     DEFAULT '365d'            NOT NULL,
	hk_history_mode          integer         DEFAULT '1'               NOT NULL,
	hk_history_global        integer         DEFAULT '0'               NOT NULL,
	hk_history               varchar(32)     DEFAULT '90d'             NOT NULL,
	hk_trends_mode           integer         DEFAULT '1'               NOT NULL,
	hk_trends_global         integer         DEFAULT '0'               NOT NULL,
	hk_trends                varchar(32)     DEFAULT '365d'            NOT NULL,
	default_inventory_mode   integer         DEFAULT '-1'              NOT NULL,
	custom_color             integer         DEFAULT '0'               NOT NULL,
	http_auth_enabled        integer         DEFAULT '0'               NOT NULL,
	http_login_form          integer         DEFAULT '0'               NOT NULL,
	http_strip_domains       varchar(2048)   DEFAULT ''                NOT NULL,
	http_case_sensitive      integer         DEFAULT '1'               NOT NULL,
	ldap_configured          integer         DEFAULT '0'               NOT NULL,
	ldap_case_sensitive      integer         DEFAULT '1'               NOT NULL,
	db_extension             varchar(32)     DEFAULT ''                NOT NULL,
	autoreg_tls_accept       integer         DEFAULT '1'               NOT NULL,
	compression_status       integer         DEFAULT '0'               NOT NULL,
	compression_availability integer         DEFAULT '0'               NOT NULL,
	compress_older           varchar(32)     DEFAULT '7d'              NOT NULL,
	instanceid               varchar(32)     DEFAULT ''                NOT NULL,
	saml_auth_enabled        integer         DEFAULT '0'               NOT NULL,
	saml_idp_entityid        varchar(1024)   DEFAULT ''                NOT NULL,
	saml_sso_url             varchar(2048)   DEFAULT ''                NOT NULL,
	saml_slo_url             varchar(2048)   DEFAULT ''                NOT NULL,
	saml_username_attribute  varchar(128)    DEFAULT ''                NOT NULL,
	saml_sp_entityid         varchar(1024)   DEFAULT ''                NOT NULL,
	saml_nameid_format       varchar(2048)   DEFAULT ''                NOT NULL,
	saml_sign_messages       integer         DEFAULT '0'               NOT NULL,
	saml_sign_assertions     integer         DEFAULT '0'               NOT NULL,
	saml_sign_authn_requests integer         DEFAULT '0'               NOT NULL,
	saml_sign_logout_requests integer         DEFAULT '0'               NOT NULL,
	saml_sign_logout_responses integer         DEFAULT '0'               NOT NULL,
	saml_encrypt_nameid      integer         DEFAULT '0'               NOT NULL,
	saml_encrypt_assertions  integer         DEFAULT '0'               NOT NULL,
	saml_case_sensitive      integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (configid)
);
CREATE INDEX config_1 ON config (alert_usrgrpid);
CREATE INDEX config_2 ON config (discovery_groupid);
CREATE TABLE triggers (
	triggerid                bigint                                    NOT NULL,
	expression               varchar(2048)   DEFAULT ''                NOT NULL,
	description              varchar(255)    DEFAULT ''                NOT NULL,
	url                      varchar(255)    DEFAULT ''                NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	value                    integer         DEFAULT '0'               NOT NULL,
	priority                 integer         DEFAULT '0'               NOT NULL,
	lastchange               integer         DEFAULT '0'               NOT NULL,
	comments                 text            DEFAULT ''                NOT NULL,
	error                    varchar(2048)   DEFAULT ''                NOT NULL,
	templateid               bigint                                    NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	state                    integer         DEFAULT '0'               NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	recovery_mode            integer         DEFAULT '0'               NOT NULL,
	recovery_expression      varchar(2048)   DEFAULT ''                NOT NULL,
	correlation_mode         integer         DEFAULT '0'               NOT NULL,
	correlation_tag          varchar(255)    DEFAULT ''                NOT NULL,
	manual_close             integer         DEFAULT '0'               NOT NULL,
	opdata                   varchar(255)    DEFAULT ''                NOT NULL,
	discover                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (triggerid)
);
CREATE INDEX triggers_1 ON triggers (status);
CREATE INDEX triggers_2 ON triggers (value,lastchange);
CREATE INDEX triggers_3 ON triggers (templateid);
CREATE TABLE trigger_depends (
	triggerdepid             bigint                                    NOT NULL,
	triggerid_down           bigint                                    NOT NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	triggerid_up             bigint                                    NOT NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	PRIMARY KEY (triggerdepid)
);
CREATE UNIQUE INDEX trigger_depends_1 ON trigger_depends (triggerid_down,triggerid_up);
CREATE INDEX trigger_depends_2 ON trigger_depends (triggerid_up);
CREATE TABLE functions (
	functionid               bigint                                    NOT NULL,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	triggerid                bigint                                    NOT NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	name                     varchar(12)     DEFAULT ''                NOT NULL,
	parameter                varchar(255)    DEFAULT '0'               NOT NULL,
	PRIMARY KEY (functionid)
);
CREATE INDEX functions_1 ON functions (triggerid);
CREATE INDEX functions_2 ON functions (itemid,name,parameter);
CREATE TABLE graphs (
	graphid                  bigint                                    NOT NULL,
	name                     varchar(128)    DEFAULT ''                NOT NULL,
	width                    integer         DEFAULT '900'             NOT NULL,
	height                   integer         DEFAULT '200'             NOT NULL,
	yaxismin                 DOUBLE PRECISION DEFAULT '0'               NOT NULL,
	yaxismax                 DOUBLE PRECISION DEFAULT '100'             NOT NULL,
	templateid               bigint                                    NULL REFERENCES graphs (graphid) ON DELETE CASCADE,
	show_work_period         integer         DEFAULT '1'               NOT NULL,
	show_triggers            integer         DEFAULT '1'               NOT NULL,
	graphtype                integer         DEFAULT '0'               NOT NULL,
	show_legend              integer         DEFAULT '1'               NOT NULL,
	show_3d                  integer         DEFAULT '0'               NOT NULL,
	percent_left             DOUBLE PRECISION DEFAULT '0'               NOT NULL,
	percent_right            DOUBLE PRECISION DEFAULT '0'               NOT NULL,
	ymin_type                integer         DEFAULT '0'               NOT NULL,
	ymax_type                integer         DEFAULT '0'               NOT NULL,
	ymin_itemid              bigint                                    NULL REFERENCES items (itemid),
	ymax_itemid              bigint                                    NULL REFERENCES items (itemid),
	flags                    integer         DEFAULT '0'               NOT NULL,
	discover                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (graphid)
);
CREATE INDEX graphs_1 ON graphs (name);
CREATE INDEX graphs_2 ON graphs (templateid);
CREATE INDEX graphs_3 ON graphs (ymin_itemid);
CREATE INDEX graphs_4 ON graphs (ymax_itemid);
CREATE TABLE graphs_items (
	gitemid                  bigint                                    NOT NULL,
	graphid                  bigint                                    NOT NULL REFERENCES graphs (graphid) ON DELETE CASCADE,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	drawtype                 integer         DEFAULT '0'               NOT NULL,
	sortorder                integer         DEFAULT '0'               NOT NULL,
	color                    varchar(6)      DEFAULT '009600'          NOT NULL,
	yaxisside                integer         DEFAULT '0'               NOT NULL,
	calc_fnc                 integer         DEFAULT '2'               NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (gitemid)
);
CREATE INDEX graphs_items_1 ON graphs_items (itemid);
CREATE INDEX graphs_items_2 ON graphs_items (graphid);
CREATE TABLE graph_theme (
	graphthemeid             bigint                                    NOT NULL,
	theme                    varchar(64)     DEFAULT ''                NOT NULL,
	backgroundcolor          varchar(6)      DEFAULT ''                NOT NULL,
	graphcolor               varchar(6)      DEFAULT ''                NOT NULL,
	gridcolor                varchar(6)      DEFAULT ''                NOT NULL,
	maingridcolor            varchar(6)      DEFAULT ''                NOT NULL,
	gridbordercolor          varchar(6)      DEFAULT ''                NOT NULL,
	textcolor                varchar(6)      DEFAULT ''                NOT NULL,
	highlightcolor           varchar(6)      DEFAULT ''                NOT NULL,
	leftpercentilecolor      varchar(6)      DEFAULT ''                NOT NULL,
	rightpercentilecolor     varchar(6)      DEFAULT ''                NOT NULL,
	nonworktimecolor         varchar(6)      DEFAULT ''                NOT NULL,
	colorpalette             varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (graphthemeid)
);
CREATE UNIQUE INDEX graph_theme_1 ON graph_theme (theme);
CREATE TABLE globalmacro (
	globalmacroid            bigint                                    NOT NULL,
	macro                    varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	description              text            DEFAULT ''                NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (globalmacroid)
);
CREATE UNIQUE INDEX globalmacro_1 ON globalmacro (macro);
CREATE TABLE hostmacro (
	hostmacroid              bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	macro                    varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	description              text            DEFAULT ''                NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (hostmacroid)
);
CREATE UNIQUE INDEX hostmacro_1 ON hostmacro (hostid,macro);
CREATE TABLE hosts_groups (
	hostgroupid              bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	groupid                  bigint                                    NOT NULL REFERENCES hstgrp (groupid) ON DELETE CASCADE,
	PRIMARY KEY (hostgroupid)
);
CREATE UNIQUE INDEX hosts_groups_1 ON hosts_groups (hostid,groupid);
CREATE INDEX hosts_groups_2 ON hosts_groups (groupid);
CREATE TABLE hosts_templates (
	hosttemplateid           bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	templateid               bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	PRIMARY KEY (hosttemplateid)
);
CREATE UNIQUE INDEX hosts_templates_1 ON hosts_templates (hostid,templateid);
CREATE INDEX hosts_templates_2 ON hosts_templates (templateid);
CREATE TABLE items_applications (
	itemappid                bigint                                    NOT NULL,
	applicationid            bigint                                    NOT NULL REFERENCES applications (applicationid) ON DELETE CASCADE,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	PRIMARY KEY (itemappid)
);
CREATE UNIQUE INDEX items_applications_1 ON items_applications (applicationid,itemid);
CREATE INDEX items_applications_2 ON items_applications (itemid);
CREATE TABLE mappings (
	mappingid                bigint                                    NOT NULL,
	valuemapid               bigint                                    NOT NULL REFERENCES valuemaps (valuemapid) ON DELETE CASCADE,
	value                    varchar(64)     DEFAULT ''                NOT NULL,
	newvalue                 varchar(64)     DEFAULT ''                NOT NULL,
	PRIMARY KEY (mappingid)
);
CREATE INDEX mappings_1 ON mappings (valuemapid);
CREATE TABLE media (
	mediaid                  bigint                                    NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	mediatypeid              bigint                                    NOT NULL REFERENCES media_type (mediatypeid) ON DELETE CASCADE,
	sendto                   varchar(1024)   DEFAULT ''                NOT NULL,
	active                   integer         DEFAULT '0'               NOT NULL,
	severity                 integer         DEFAULT '63'              NOT NULL,
	period                   varchar(1024)   DEFAULT '1-7,00:00-24:00' NOT NULL,
	PRIMARY KEY (mediaid)
);
CREATE INDEX media_1 ON media (userid);
CREATE INDEX media_2 ON media (mediatypeid);
CREATE TABLE rights (
	rightid                  bigint                                    NOT NULL,
	groupid                  bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid) ON DELETE CASCADE,
	permission               integer         DEFAULT '0'               NOT NULL,
	id                       bigint                                    NOT NULL REFERENCES hstgrp (groupid) ON DELETE CASCADE,
	PRIMARY KEY (rightid)
);
CREATE INDEX rights_1 ON rights (groupid);
CREATE INDEX rights_2 ON rights (id);
CREATE TABLE services (
	serviceid                bigint                                    NOT NULL,
	name                     varchar(128)    DEFAULT ''                NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	algorithm                integer         DEFAULT '0'               NOT NULL,
	triggerid                bigint                                    NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	showsla                  integer         DEFAULT '0'               NOT NULL,
	goodsla                  DOUBLE PRECISION DEFAULT '99.9'            NOT NULL,
	sortorder                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (serviceid)
);
CREATE INDEX services_1 ON services (triggerid);
CREATE TABLE services_links (
	linkid                   bigint                                    NOT NULL,
	serviceupid              bigint                                    NOT NULL REFERENCES services (serviceid) ON DELETE CASCADE,
	servicedownid            bigint                                    NOT NULL REFERENCES services (serviceid) ON DELETE CASCADE,
	soft                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (linkid)
);
CREATE INDEX services_links_1 ON services_links (servicedownid);
CREATE UNIQUE INDEX services_links_2 ON services_links (serviceupid,servicedownid);
CREATE TABLE services_times (
	timeid                   bigint                                    NOT NULL,
	serviceid                bigint                                    NOT NULL REFERENCES services (serviceid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	ts_from                  integer         DEFAULT '0'               NOT NULL,
	ts_to                    integer         DEFAULT '0'               NOT NULL,
	note                     varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (timeid)
);
CREATE INDEX services_times_1 ON services_times (serviceid,type,ts_from,ts_to);
CREATE TABLE icon_map (
	iconmapid                bigint                                    NOT NULL,
	name                     varchar(64)     DEFAULT ''                NOT NULL,
	default_iconid           bigint                                    NOT NULL REFERENCES images (imageid),
	PRIMARY KEY (iconmapid)
);
CREATE UNIQUE INDEX icon_map_1 ON icon_map (name);
CREATE INDEX icon_map_2 ON icon_map (default_iconid);
CREATE TABLE icon_mapping (
	iconmappingid            bigint                                    NOT NULL,
	iconmapid                bigint                                    NOT NULL REFERENCES icon_map (iconmapid) ON DELETE CASCADE,
	iconid                   bigint                                    NOT NULL REFERENCES images (imageid),
	inventory_link           integer         DEFAULT '0'               NOT NULL,
	expression               varchar(64)     DEFAULT ''                NOT NULL,
	sortorder                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (iconmappingid)
);
CREATE INDEX icon_mapping_1 ON icon_mapping (iconmapid);
CREATE INDEX icon_mapping_2 ON icon_mapping (iconid);
CREATE TABLE sysmaps (
	sysmapid                 bigint                                    NOT NULL,
	name                     varchar(128)    DEFAULT ''                NOT NULL,
	width                    integer         DEFAULT '600'             NOT NULL,
	height                   integer         DEFAULT '400'             NOT NULL,
	backgroundid             bigint                                    NULL REFERENCES images (imageid),
	label_type               integer         DEFAULT '2'               NOT NULL,
	label_location           integer         DEFAULT '0'               NOT NULL,
	highlight                integer         DEFAULT '1'               NOT NULL,
	expandproblem            integer         DEFAULT '1'               NOT NULL,
	markelements             integer         DEFAULT '0'               NOT NULL,
	show_unack               integer         DEFAULT '0'               NOT NULL,
	grid_size                integer         DEFAULT '50'              NOT NULL,
	grid_show                integer         DEFAULT '1'               NOT NULL,
	grid_align               integer         DEFAULT '1'               NOT NULL,
	label_format             integer         DEFAULT '0'               NOT NULL,
	label_type_host          integer         DEFAULT '2'               NOT NULL,
	label_type_hostgroup     integer         DEFAULT '2'               NOT NULL,
	label_type_trigger       integer         DEFAULT '2'               NOT NULL,
	label_type_map           integer         DEFAULT '2'               NOT NULL,
	label_type_image         integer         DEFAULT '2'               NOT NULL,
	label_string_host        varchar(255)    DEFAULT ''                NOT NULL,
	label_string_hostgroup   varchar(255)    DEFAULT ''                NOT NULL,
	label_string_trigger     varchar(255)    DEFAULT ''                NOT NULL,
	label_string_map         varchar(255)    DEFAULT ''                NOT NULL,
	label_string_image       varchar(255)    DEFAULT ''                NOT NULL,
	iconmapid                bigint                                    NULL REFERENCES icon_map (iconmapid),
	expand_macros            integer         DEFAULT '0'               NOT NULL,
	severity_min             integer         DEFAULT '0'               NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid),
	private                  integer         DEFAULT '1'               NOT NULL,
	show_suppressed          integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (sysmapid)
);
CREATE UNIQUE INDEX sysmaps_1 ON sysmaps (name);
CREATE INDEX sysmaps_2 ON sysmaps (backgroundid);
CREATE INDEX sysmaps_3 ON sysmaps (iconmapid);
CREATE TABLE sysmaps_elements (
	selementid               bigint                                    NOT NULL,
	sysmapid                 bigint                                    NOT NULL REFERENCES sysmaps (sysmapid) ON DELETE CASCADE,
	elementid                bigint          DEFAULT '0'               NOT NULL,
	elementtype              integer         DEFAULT '0'               NOT NULL,
	iconid_off               bigint                                    NULL REFERENCES images (imageid),
	iconid_on                bigint                                    NULL REFERENCES images (imageid),
	label                    varchar(2048)   DEFAULT ''                NOT NULL,
	label_location           integer         DEFAULT '-1'              NOT NULL,
	x                        integer         DEFAULT '0'               NOT NULL,
	y                        integer         DEFAULT '0'               NOT NULL,
	iconid_disabled          bigint                                    NULL REFERENCES images (imageid),
	iconid_maintenance       bigint                                    NULL REFERENCES images (imageid),
	elementsubtype           integer         DEFAULT '0'               NOT NULL,
	areatype                 integer         DEFAULT '0'               NOT NULL,
	width                    integer         DEFAULT '200'             NOT NULL,
	height                   integer         DEFAULT '200'             NOT NULL,
	viewtype                 integer         DEFAULT '0'               NOT NULL,
	use_iconmap              integer         DEFAULT '1'               NOT NULL,
	application              varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (selementid)
);
CREATE INDEX sysmaps_elements_1 ON sysmaps_elements (sysmapid);
CREATE INDEX sysmaps_elements_2 ON sysmaps_elements (iconid_off);
CREATE INDEX sysmaps_elements_3 ON sysmaps_elements (iconid_on);
CREATE INDEX sysmaps_elements_4 ON sysmaps_elements (iconid_disabled);
CREATE INDEX sysmaps_elements_5 ON sysmaps_elements (iconid_maintenance);
CREATE TABLE sysmaps_links (
	linkid                   bigint                                    NOT NULL,
	sysmapid                 bigint                                    NOT NULL REFERENCES sysmaps (sysmapid) ON DELETE CASCADE,
	selementid1              bigint                                    NOT NULL REFERENCES sysmaps_elements (selementid) ON DELETE CASCADE,
	selementid2              bigint                                    NOT NULL REFERENCES sysmaps_elements (selementid) ON DELETE CASCADE,
	drawtype                 integer         DEFAULT '0'               NOT NULL,
	color                    varchar(6)      DEFAULT '000000'          NOT NULL,
	label                    varchar(2048)   DEFAULT ''                NOT NULL,
	PRIMARY KEY (linkid)
);
CREATE INDEX sysmaps_links_1 ON sysmaps_links (sysmapid);
CREATE INDEX sysmaps_links_2 ON sysmaps_links (selementid1);
CREATE INDEX sysmaps_links_3 ON sysmaps_links (selementid2);
CREATE TABLE sysmaps_link_triggers (
	linktriggerid            bigint                                    NOT NULL,
	linkid                   bigint                                    NOT NULL REFERENCES sysmaps_links (linkid) ON DELETE CASCADE,
	triggerid                bigint                                    NOT NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	drawtype                 integer         DEFAULT '0'               NOT NULL,
	color                    varchar(6)      DEFAULT '000000'          NOT NULL,
	PRIMARY KEY (linktriggerid)
);
CREATE UNIQUE INDEX sysmaps_link_triggers_1 ON sysmaps_link_triggers (linkid,triggerid);
CREATE INDEX sysmaps_link_triggers_2 ON sysmaps_link_triggers (triggerid);
CREATE TABLE sysmap_element_url (
	sysmapelementurlid       bigint                                    NOT NULL,
	selementid               bigint                                    NOT NULL REFERENCES sysmaps_elements (selementid) ON DELETE CASCADE,
	name                     varchar(255)                              NOT NULL,
	url                      varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (sysmapelementurlid)
);
CREATE UNIQUE INDEX sysmap_element_url_1 ON sysmap_element_url (selementid,name);
CREATE TABLE sysmap_url (
	sysmapurlid              bigint                                    NOT NULL,
	sysmapid                 bigint                                    NOT NULL REFERENCES sysmaps (sysmapid) ON DELETE CASCADE,
	name                     varchar(255)                              NOT NULL,
	url                      varchar(255)    DEFAULT ''                NOT NULL,
	elementtype              integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (sysmapurlid)
);
CREATE UNIQUE INDEX sysmap_url_1 ON sysmap_url (sysmapid,name);
CREATE TABLE sysmap_user (
	sysmapuserid             bigint                                    NOT NULL,
	sysmapid                 bigint                                    NOT NULL REFERENCES sysmaps (sysmapid) ON DELETE CASCADE,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (sysmapuserid)
);
CREATE UNIQUE INDEX sysmap_user_1 ON sysmap_user (sysmapid,userid);
CREATE TABLE sysmap_usrgrp (
	sysmapusrgrpid           bigint                                    NOT NULL,
	sysmapid                 bigint                                    NOT NULL REFERENCES sysmaps (sysmapid) ON DELETE CASCADE,
	usrgrpid                 bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (sysmapusrgrpid)
);
CREATE UNIQUE INDEX sysmap_usrgrp_1 ON sysmap_usrgrp (sysmapid,usrgrpid);
CREATE TABLE maintenances_hosts (
	maintenance_hostid       bigint                                    NOT NULL,
	maintenanceid            bigint                                    NOT NULL REFERENCES maintenances (maintenanceid) ON DELETE CASCADE,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	PRIMARY KEY (maintenance_hostid)
);
CREATE UNIQUE INDEX maintenances_hosts_1 ON maintenances_hosts (maintenanceid,hostid);
CREATE INDEX maintenances_hosts_2 ON maintenances_hosts (hostid);
CREATE TABLE maintenances_groups (
	maintenance_groupid      bigint                                    NOT NULL,
	maintenanceid            bigint                                    NOT NULL REFERENCES maintenances (maintenanceid) ON DELETE CASCADE,
	groupid                  bigint                                    NOT NULL REFERENCES hstgrp (groupid) ON DELETE CASCADE,
	PRIMARY KEY (maintenance_groupid)
);
CREATE UNIQUE INDEX maintenances_groups_1 ON maintenances_groups (maintenanceid,groupid);
CREATE INDEX maintenances_groups_2 ON maintenances_groups (groupid);
CREATE TABLE timeperiods (
	timeperiodid             bigint                                    NOT NULL,
	timeperiod_type          integer         DEFAULT '0'               NOT NULL,
	every                    integer         DEFAULT '1'               NOT NULL,
	month                    integer         DEFAULT '0'               NOT NULL,
	dayofweek                integer         DEFAULT '0'               NOT NULL,
	day                      integer         DEFAULT '0'               NOT NULL,
	start_time               integer         DEFAULT '0'               NOT NULL,
	period                   integer         DEFAULT '0'               NOT NULL,
	start_date               integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (timeperiodid)
);
CREATE TABLE maintenances_windows (
	maintenance_timeperiodid bigint                                    NOT NULL,
	maintenanceid            bigint                                    NOT NULL REFERENCES maintenances (maintenanceid) ON DELETE CASCADE,
	timeperiodid             bigint                                    NOT NULL REFERENCES timeperiods (timeperiodid) ON DELETE CASCADE,
	PRIMARY KEY (maintenance_timeperiodid)
);
CREATE UNIQUE INDEX maintenances_windows_1 ON maintenances_windows (maintenanceid,timeperiodid);
CREATE INDEX maintenances_windows_2 ON maintenances_windows (timeperiodid);
CREATE TABLE regexps (
	regexpid                 bigint                                    NOT NULL,
	name                     varchar(128)    DEFAULT ''                NOT NULL,
	test_string              text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (regexpid)
);
CREATE UNIQUE INDEX regexps_1 ON regexps (name);
CREATE TABLE expressions (
	expressionid             bigint                                    NOT NULL,
	regexpid                 bigint                                    NOT NULL REFERENCES regexps (regexpid) ON DELETE CASCADE,
	expression               varchar(255)    DEFAULT ''                NOT NULL,
	expression_type          integer         DEFAULT '0'               NOT NULL,
	exp_delimiter            varchar(1)      DEFAULT ''                NOT NULL,
	case_sensitive           integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (expressionid)
);
CREATE INDEX expressions_1 ON expressions (regexpid);
CREATE TABLE ids (
	table_name               varchar(64)     DEFAULT ''                NOT NULL,
	field_name               varchar(64)     DEFAULT ''                NOT NULL,
	nextid                   bigint                                    NOT NULL,
	PRIMARY KEY (table_name,field_name)
);
CREATE TABLE alerts (
	alertid                  bigint                                    NOT NULL,
	actionid                 bigint                                    NOT NULL REFERENCES actions (actionid) ON DELETE CASCADE,
	eventid                  bigint                                    NOT NULL REFERENCES events (eventid) ON DELETE CASCADE,
	userid                   bigint                                    NULL REFERENCES users (userid) ON DELETE CASCADE,
	clock                    integer         DEFAULT '0'               NOT NULL,
	mediatypeid              bigint                                    NULL REFERENCES media_type (mediatypeid) ON DELETE CASCADE,
	sendto                   varchar(1024)   DEFAULT ''                NOT NULL,
	subject                  varchar(255)    DEFAULT ''                NOT NULL,
	message                  text            DEFAULT ''                NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	retries                  integer         DEFAULT '0'               NOT NULL,
	error                    varchar(2048)   DEFAULT ''                NOT NULL,
	esc_step                 integer         DEFAULT '0'               NOT NULL,
	alerttype                integer         DEFAULT '0'               NOT NULL,
	p_eventid                bigint                                    NULL REFERENCES events (eventid) ON DELETE CASCADE,
	acknowledgeid            bigint                                    NULL REFERENCES acknowledges (acknowledgeid) ON DELETE CASCADE,
	parameters               text            DEFAULT '{}'              NOT NULL,
	PRIMARY KEY (alertid)
);
CREATE INDEX alerts_1 ON alerts (actionid);
CREATE INDEX alerts_2 ON alerts (clock);
CREATE INDEX alerts_3 ON alerts (eventid);
CREATE INDEX alerts_4 ON alerts (status);
CREATE INDEX alerts_5 ON alerts (mediatypeid);
CREATE INDEX alerts_6 ON alerts (userid);
CREATE INDEX alerts_7 ON alerts (p_eventid);
CREATE TABLE history (
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	value                    DOUBLE PRECISION DEFAULT '0.0000'          NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL
);
CREATE INDEX history_1 ON history (itemid,clock);
CREATE TABLE history_uint (
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	value                    bigint          DEFAULT '0'               NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL
);
CREATE INDEX history_uint_1 ON history_uint (itemid,clock);
CREATE TABLE history_str (
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL
);
CREATE INDEX history_str_1 ON history_str (itemid,clock);
CREATE TABLE history_log (
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	timestamp                integer         DEFAULT '0'               NOT NULL,
	source                   varchar(64)     DEFAULT ''                NOT NULL,
	severity                 integer         DEFAULT '0'               NOT NULL,
	value                    text            DEFAULT ''                NOT NULL,
	logeventid               integer         DEFAULT '0'               NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL
);
CREATE INDEX history_log_1 ON history_log (itemid,clock);
CREATE TABLE history_text (
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	value                    text            DEFAULT ''                NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL
);
CREATE INDEX history_text_1 ON history_text (itemid,clock);
CREATE TABLE proxy_history (
	id                       integer                                   NOT NULL PRIMARY KEY AUTOINCREMENT,
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	timestamp                integer         DEFAULT '0'               NOT NULL,
	source                   varchar(64)     DEFAULT ''                NOT NULL,
	severity                 integer         DEFAULT '0'               NOT NULL,
	value                    text            DEFAULT ''                NOT NULL,
	logeventid               integer         DEFAULT '0'               NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL,
	state                    integer         DEFAULT '0'               NOT NULL,
	lastlogsize              bigint          DEFAULT '0'               NOT NULL,
	mtime                    integer         DEFAULT '0'               NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	write_clock              integer         DEFAULT '0'               NOT NULL
);
CREATE INDEX proxy_history_1 ON proxy_history (clock);
CREATE TABLE proxy_dhistory (
	id                       integer                                   NOT NULL PRIMARY KEY AUTOINCREMENT,
	clock                    integer         DEFAULT '0'               NOT NULL,
	druleid                  bigint                                    NOT NULL,
	ip                       varchar(39)     DEFAULT ''                NOT NULL,
	port                     integer         DEFAULT '0'               NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	dcheckid                 bigint                                    NULL,
	dns                      varchar(255)    DEFAULT ''                NOT NULL
);
CREATE INDEX proxy_dhistory_1 ON proxy_dhistory (clock);
CREATE INDEX proxy_dhistory_2 ON proxy_dhistory (druleid);
CREATE TABLE events (
	eventid                  bigint                                    NOT NULL,
	source                   integer         DEFAULT '0'               NOT NULL,
	object                   integer         DEFAULT '0'               NOT NULL,
	objectid                 bigint          DEFAULT '0'               NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	value                    integer         DEFAULT '0'               NOT NULL,
	acknowledged             integer         DEFAULT '0'               NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL,
	name                     varchar(2048)   DEFAULT ''                NOT NULL,
	severity                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (eventid)
);
CREATE INDEX events_1 ON events (source,object,objectid,clock);
CREATE INDEX events_2 ON events (source,object,clock);
CREATE TABLE trends (
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	num                      integer         DEFAULT '0'               NOT NULL,
	value_min                DOUBLE PRECISION DEFAULT '0.0000'          NOT NULL,
	value_avg                DOUBLE PRECISION DEFAULT '0.0000'          NOT NULL,
	value_max                DOUBLE PRECISION DEFAULT '0.0000'          NOT NULL,
	PRIMARY KEY (itemid,clock)
);
CREATE TABLE trends_uint (
	itemid                   bigint                                    NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	num                      integer         DEFAULT '0'               NOT NULL,
	value_min                bigint          DEFAULT '0'               NOT NULL,
	value_avg                bigint          DEFAULT '0'               NOT NULL,
	value_max                bigint          DEFAULT '0'               NOT NULL,
	PRIMARY KEY (itemid,clock)
);
CREATE TABLE acknowledges (
	acknowledgeid            bigint                                    NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	eventid                  bigint                                    NOT NULL REFERENCES events (eventid) ON DELETE CASCADE,
	clock                    integer         DEFAULT '0'               NOT NULL,
	message                  varchar(2048)   DEFAULT ''                NOT NULL,
	action                   integer         DEFAULT '0'               NOT NULL,
	old_severity             integer         DEFAULT '0'               NOT NULL,
	new_severity             integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (acknowledgeid)
);
CREATE INDEX acknowledges_1 ON acknowledges (userid);
CREATE INDEX acknowledges_2 ON acknowledges (eventid);
CREATE INDEX acknowledges_3 ON acknowledges (clock);
CREATE TABLE auditlog (
	auditid                  bigint                                    NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	clock                    integer         DEFAULT '0'               NOT NULL,
	action                   integer         DEFAULT '0'               NOT NULL,
	resourcetype             integer         DEFAULT '0'               NOT NULL,
	note                     varchar(128)    DEFAULT ''                NOT NULL,
	ip                       varchar(39)     DEFAULT ''                NOT NULL,
	resourceid               bigint                                    NULL,
	resourcename             varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (auditid)
);
CREATE INDEX auditlog_1 ON auditlog (userid,clock);
CREATE INDEX auditlog_2 ON auditlog (clock);
CREATE INDEX auditlog_3 ON auditlog (resourcetype,resourceid);
CREATE TABLE auditlog_details (
	auditdetailid            bigint                                    NOT NULL,
	auditid                  bigint                                    NOT NULL REFERENCES auditlog (auditid) ON DELETE CASCADE,
	table_name               varchar(64)     DEFAULT ''                NOT NULL,
	field_name               varchar(64)     DEFAULT ''                NOT NULL,
	oldvalue                 text            DEFAULT ''                NOT NULL,
	newvalue                 text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (auditdetailid)
);
CREATE INDEX auditlog_details_1 ON auditlog_details (auditid);
CREATE TABLE service_alarms (
	servicealarmid           bigint                                    NOT NULL,
	serviceid                bigint                                    NOT NULL REFERENCES services (serviceid) ON DELETE CASCADE,
	clock                    integer         DEFAULT '0'               NOT NULL,
	value                    integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (servicealarmid)
);
CREATE INDEX service_alarms_1 ON service_alarms (serviceid,clock);
CREATE INDEX service_alarms_2 ON service_alarms (clock);
CREATE TABLE autoreg_host (
	autoreg_hostid           bigint                                    NOT NULL,
	proxy_hostid             bigint                                    NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	host                     varchar(128)    DEFAULT ''                NOT NULL,
	listen_ip                varchar(39)     DEFAULT ''                NOT NULL,
	listen_port              integer         DEFAULT '0'               NOT NULL,
	listen_dns               varchar(255)    DEFAULT ''                NOT NULL,
	host_metadata            varchar(255)    DEFAULT ''                NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	tls_accepted             integer         DEFAULT '1'               NOT NULL,
	PRIMARY KEY (autoreg_hostid)
);
CREATE INDEX autoreg_host_1 ON autoreg_host (host);
CREATE INDEX autoreg_host_2 ON autoreg_host (proxy_hostid);
CREATE TABLE proxy_autoreg_host (
	id                       integer                                   NOT NULL PRIMARY KEY AUTOINCREMENT,
	clock                    integer         DEFAULT '0'               NOT NULL,
	host                     varchar(128)    DEFAULT ''                NOT NULL,
	listen_ip                varchar(39)     DEFAULT ''                NOT NULL,
	listen_port              integer         DEFAULT '0'               NOT NULL,
	listen_dns               varchar(255)    DEFAULT ''                NOT NULL,
	host_metadata            varchar(255)    DEFAULT ''                NOT NULL,
	flags                    integer         DEFAULT '0'               NOT NULL,
	tls_accepted             integer         DEFAULT '1'               NOT NULL
);
CREATE INDEX proxy_autoreg_host_1 ON proxy_autoreg_host (clock);
CREATE TABLE dhosts (
	dhostid                  bigint                                    NOT NULL,
	druleid                  bigint                                    NOT NULL REFERENCES drules (druleid) ON DELETE CASCADE,
	status                   integer         DEFAULT '0'               NOT NULL,
	lastup                   integer         DEFAULT '0'               NOT NULL,
	lastdown                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (dhostid)
);
CREATE INDEX dhosts_1 ON dhosts (druleid);
CREATE TABLE dservices (
	dserviceid               bigint                                    NOT NULL,
	dhostid                  bigint                                    NOT NULL REFERENCES dhosts (dhostid) ON DELETE CASCADE,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	port                     integer         DEFAULT '0'               NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	lastup                   integer         DEFAULT '0'               NOT NULL,
	lastdown                 integer         DEFAULT '0'               NOT NULL,
	dcheckid                 bigint                                    NOT NULL REFERENCES dchecks (dcheckid) ON DELETE CASCADE,
	ip                       varchar(39)     DEFAULT ''                NOT NULL,
	dns                      varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (dserviceid)
);
CREATE UNIQUE INDEX dservices_1 ON dservices (dcheckid,ip,port);
CREATE INDEX dservices_2 ON dservices (dhostid);
CREATE TABLE escalations (
	escalationid             bigint                                    NOT NULL,
	actionid                 bigint                                    NOT NULL,
	triggerid                bigint                                    NULL,
	eventid                  bigint                                    NULL,
	r_eventid                bigint                                    NULL,
	nextcheck                integer         DEFAULT '0'               NOT NULL,
	esc_step                 integer         DEFAULT '0'               NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	itemid                   bigint                                    NULL,
	acknowledgeid            bigint                                    NULL,
	PRIMARY KEY (escalationid)
);
CREATE UNIQUE INDEX escalations_1 ON escalations (triggerid,itemid,escalationid);
CREATE INDEX escalations_2 ON escalations (eventid);
CREATE INDEX escalations_3 ON escalations (nextcheck);
CREATE TABLE globalvars (
	globalvarid              bigint                                    NOT NULL,
	snmp_lastsize            bigint          DEFAULT '0'               NOT NULL,
	PRIMARY KEY (globalvarid)
);
CREATE TABLE graph_discovery (
	graphid                  bigint                                    NOT NULL REFERENCES graphs (graphid) ON DELETE CASCADE,
	parent_graphid           bigint                                    NOT NULL REFERENCES graphs (graphid),
	lastcheck                integer         DEFAULT '0'               NOT NULL,
	ts_delete                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (graphid)
);
CREATE INDEX graph_discovery_1 ON graph_discovery (parent_graphid);
CREATE TABLE host_inventory (
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	inventory_mode           integer         DEFAULT '0'               NOT NULL,
	type                     varchar(64)     DEFAULT ''                NOT NULL,
	type_full                varchar(64)     DEFAULT ''                NOT NULL,
	name                     varchar(128)    DEFAULT ''                NOT NULL,
	alias                    varchar(128)    DEFAULT ''                NOT NULL,
	os                       varchar(128)    DEFAULT ''                NOT NULL,
	os_full                  varchar(255)    DEFAULT ''                NOT NULL,
	os_short                 varchar(128)    DEFAULT ''                NOT NULL,
	serialno_a               varchar(64)     DEFAULT ''                NOT NULL,
	serialno_b               varchar(64)     DEFAULT ''                NOT NULL,
	tag                      varchar(64)     DEFAULT ''                NOT NULL,
	asset_tag                varchar(64)     DEFAULT ''                NOT NULL,
	macaddress_a             varchar(64)     DEFAULT ''                NOT NULL,
	macaddress_b             varchar(64)     DEFAULT ''                NOT NULL,
	hardware                 varchar(255)    DEFAULT ''                NOT NULL,
	hardware_full            text            DEFAULT ''                NOT NULL,
	software                 varchar(255)    DEFAULT ''                NOT NULL,
	software_full            text            DEFAULT ''                NOT NULL,
	software_app_a           varchar(64)     DEFAULT ''                NOT NULL,
	software_app_b           varchar(64)     DEFAULT ''                NOT NULL,
	software_app_c           varchar(64)     DEFAULT ''                NOT NULL,
	software_app_d           varchar(64)     DEFAULT ''                NOT NULL,
	software_app_e           varchar(64)     DEFAULT ''                NOT NULL,
	contact                  text            DEFAULT ''                NOT NULL,
	location                 text            DEFAULT ''                NOT NULL,
	location_lat             varchar(16)     DEFAULT ''                NOT NULL,
	location_lon             varchar(16)     DEFAULT ''                NOT NULL,
	notes                    text            DEFAULT ''                NOT NULL,
	chassis                  varchar(64)     DEFAULT ''                NOT NULL,
	model                    varchar(64)     DEFAULT ''                NOT NULL,
	hw_arch                  varchar(32)     DEFAULT ''                NOT NULL,
	vendor                   varchar(64)     DEFAULT ''                NOT NULL,
	contract_number          varchar(64)     DEFAULT ''                NOT NULL,
	installer_name           varchar(64)     DEFAULT ''                NOT NULL,
	deployment_status        varchar(64)     DEFAULT ''                NOT NULL,
	url_a                    varchar(255)    DEFAULT ''                NOT NULL,
	url_b                    varchar(255)    DEFAULT ''                NOT NULL,
	url_c                    varchar(255)    DEFAULT ''                NOT NULL,
	host_networks            text            DEFAULT ''                NOT NULL,
	host_netmask             varchar(39)     DEFAULT ''                NOT NULL,
	host_router              varchar(39)     DEFAULT ''                NOT NULL,
	oob_ip                   varchar(39)     DEFAULT ''                NOT NULL,
	oob_netmask              varchar(39)     DEFAULT ''                NOT NULL,
	oob_router               varchar(39)     DEFAULT ''                NOT NULL,
	date_hw_purchase         varchar(64)     DEFAULT ''                NOT NULL,
	date_hw_install          varchar(64)     DEFAULT ''                NOT NULL,
	date_hw_expiry           varchar(64)     DEFAULT ''                NOT NULL,
	date_hw_decomm           varchar(64)     DEFAULT ''                NOT NULL,
	site_address_a           varchar(128)    DEFAULT ''                NOT NULL,
	site_address_b           varchar(128)    DEFAULT ''                NOT NULL,
	site_address_c           varchar(128)    DEFAULT ''                NOT NULL,
	site_city                varchar(128)    DEFAULT ''                NOT NULL,
	site_state               varchar(64)     DEFAULT ''                NOT NULL,
	site_country             varchar(64)     DEFAULT ''                NOT NULL,
	site_zip                 varchar(64)     DEFAULT ''                NOT NULL,
	site_rack                varchar(128)    DEFAULT ''                NOT NULL,
	site_notes               text            DEFAULT ''                NOT NULL,
	poc_1_name               varchar(128)    DEFAULT ''                NOT NULL,
	poc_1_email              varchar(128)    DEFAULT ''                NOT NULL,
	poc_1_phone_a            varchar(64)     DEFAULT ''                NOT NULL,
	poc_1_phone_b            varchar(64)     DEFAULT ''                NOT NULL,
	poc_1_cell               varchar(64)     DEFAULT ''                NOT NULL,
	poc_1_screen             varchar(64)     DEFAULT ''                NOT NULL,
	poc_1_notes              text            DEFAULT ''                NOT NULL,
	poc_2_name               varchar(128)    DEFAULT ''                NOT NULL,
	poc_2_email              varchar(128)    DEFAULT ''                NOT NULL,
	poc_2_phone_a            varchar(64)     DEFAULT ''                NOT NULL,
	poc_2_phone_b            varchar(64)     DEFAULT ''                NOT NULL,
	poc_2_cell               varchar(64)     DEFAULT ''                NOT NULL,
	poc_2_screen             varchar(64)     DEFAULT ''                NOT NULL,
	poc_2_notes              text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (hostid)
);
CREATE TABLE housekeeper (
	housekeeperid            bigint                                    NOT NULL,
	tablename                varchar(64)     DEFAULT ''                NOT NULL,
	field                    varchar(64)     DEFAULT ''                NOT NULL,
	value                    bigint                                    NOT NULL,
	PRIMARY KEY (housekeeperid)
);
CREATE TABLE images (
	imageid                  bigint                                    NOT NULL,
	imagetype                integer         DEFAULT '0'               NOT NULL,
	name                     varchar(64)     DEFAULT '0'               NOT NULL,
	image                    longblob        DEFAULT ''                NOT NULL,
	PRIMARY KEY (imageid)
);
CREATE UNIQUE INDEX images_1 ON images (name);
CREATE TABLE item_discovery (
	itemdiscoveryid          bigint                                    NOT NULL,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	parent_itemid            bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	key_                     varchar(2048)   DEFAULT ''                NOT NULL,
	lastcheck                integer         DEFAULT '0'               NOT NULL,
	ts_delete                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (itemdiscoveryid)
);
CREATE UNIQUE INDEX item_discovery_1 ON item_discovery (itemid,parent_itemid);
CREATE INDEX item_discovery_2 ON item_discovery (parent_itemid);
CREATE TABLE host_discovery (
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	parent_hostid            bigint                                    NULL REFERENCES hosts (hostid),
	parent_itemid            bigint                                    NULL REFERENCES items (itemid),
	host                     varchar(128)    DEFAULT ''                NOT NULL,
	lastcheck                integer         DEFAULT '0'               NOT NULL,
	ts_delete                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (hostid)
);
CREATE TABLE interface_discovery (
	interfaceid              bigint                                    NOT NULL REFERENCES interface (interfaceid) ON DELETE CASCADE,
	parent_interfaceid       bigint                                    NOT NULL REFERENCES interface (interfaceid) ON DELETE CASCADE,
	PRIMARY KEY (interfaceid)
);
CREATE TABLE profiles (
	profileid                bigint                                    NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	idx                      varchar(96)     DEFAULT ''                NOT NULL,
	idx2                     bigint          DEFAULT '0'               NOT NULL,
	value_id                 bigint          DEFAULT '0'               NOT NULL,
	value_int                integer         DEFAULT '0'               NOT NULL,
	value_str                varchar(255)    DEFAULT ''                NOT NULL,
	source                   varchar(96)     DEFAULT ''                NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (profileid)
);
CREATE INDEX profiles_1 ON profiles (userid,idx,idx2);
CREATE INDEX profiles_2 ON profiles (userid,profileid);
CREATE TABLE sessions (
	sessionid                varchar(32)     DEFAULT ''                NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	lastaccess               integer         DEFAULT '0'               NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (sessionid)
);
CREATE INDEX sessions_1 ON sessions (userid,status,lastaccess);
CREATE TABLE trigger_discovery (
	triggerid                bigint                                    NOT NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	parent_triggerid         bigint                                    NOT NULL REFERENCES triggers (triggerid),
	lastcheck                integer         DEFAULT '0'               NOT NULL,
	ts_delete                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (triggerid)
);
CREATE INDEX trigger_discovery_1 ON trigger_discovery (parent_triggerid);
CREATE TABLE application_template (
	application_templateid   bigint                                    NOT NULL,
	applicationid            bigint                                    NOT NULL REFERENCES applications (applicationid) ON DELETE CASCADE,
	templateid               bigint                                    NOT NULL REFERENCES applications (applicationid) ON DELETE CASCADE,
	PRIMARY KEY (application_templateid)
);
CREATE UNIQUE INDEX application_template_1 ON application_template (applicationid,templateid);
CREATE INDEX application_template_2 ON application_template (templateid);
CREATE TABLE item_condition (
	item_conditionid         bigint                                    NOT NULL,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	operator                 integer         DEFAULT '8'               NOT NULL,
	macro                    varchar(64)     DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (item_conditionid)
);
CREATE INDEX item_condition_1 ON item_condition (itemid);
CREATE TABLE item_rtdata (
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	lastlogsize              bigint          DEFAULT '0'               NOT NULL,
	state                    integer         DEFAULT '0'               NOT NULL,
	mtime                    integer         DEFAULT '0'               NOT NULL,
	error                    varchar(2048)   DEFAULT ''                NOT NULL,
	PRIMARY KEY (itemid)
);
CREATE TABLE application_prototype (
	application_prototypeid  bigint                                    NOT NULL,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	templateid               bigint                                    NULL REFERENCES application_prototype (application_prototypeid) ON DELETE CASCADE,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (application_prototypeid)
);
CREATE INDEX application_prototype_1 ON application_prototype (itemid);
CREATE INDEX application_prototype_2 ON application_prototype (templateid);
CREATE TABLE item_application_prototype (
	item_application_prototypeid bigint                                    NOT NULL,
	application_prototypeid  bigint                                    NOT NULL REFERENCES application_prototype (application_prototypeid) ON DELETE CASCADE,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	PRIMARY KEY (item_application_prototypeid)
);
CREATE UNIQUE INDEX item_application_prototype_1 ON item_application_prototype (application_prototypeid,itemid);
CREATE INDEX item_application_prototype_2 ON item_application_prototype (itemid);
CREATE TABLE application_discovery (
	application_discoveryid  bigint                                    NOT NULL,
	applicationid            bigint                                    NOT NULL REFERENCES applications (applicationid) ON DELETE CASCADE,
	application_prototypeid  bigint                                    NOT NULL REFERENCES application_prototype (application_prototypeid) ON DELETE CASCADE,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	lastcheck                integer         DEFAULT '0'               NOT NULL,
	ts_delete                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (application_discoveryid)
);
CREATE INDEX application_discovery_1 ON application_discovery (applicationid);
CREATE INDEX application_discovery_2 ON application_discovery (application_prototypeid);
CREATE TABLE opinventory (
	operationid              bigint                                    NOT NULL REFERENCES operations (operationid) ON DELETE CASCADE,
	inventory_mode           integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (operationid)
);
CREATE TABLE trigger_tag (
	triggertagid             bigint                                    NOT NULL,
	triggerid                bigint                                    NOT NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (triggertagid)
);
CREATE INDEX trigger_tag_1 ON trigger_tag (triggerid);
CREATE TABLE event_tag (
	eventtagid               bigint                                    NOT NULL,
	eventid                  bigint                                    NOT NULL REFERENCES events (eventid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (eventtagid)
);
CREATE INDEX event_tag_1 ON event_tag (eventid);
CREATE TABLE problem (
	eventid                  bigint                                    NOT NULL REFERENCES events (eventid) ON DELETE CASCADE,
	source                   integer         DEFAULT '0'               NOT NULL,
	object                   integer         DEFAULT '0'               NOT NULL,
	objectid                 bigint          DEFAULT '0'               NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	ns                       integer         DEFAULT '0'               NOT NULL,
	r_eventid                bigint                                    NULL REFERENCES events (eventid) ON DELETE CASCADE,
	r_clock                  integer         DEFAULT '0'               NOT NULL,
	r_ns                     integer         DEFAULT '0'               NOT NULL,
	correlationid            bigint                                    NULL,
	userid                   bigint                                    NULL,
	name                     varchar(2048)   DEFAULT ''                NOT NULL,
	acknowledged             integer         DEFAULT '0'               NOT NULL,
	severity                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (eventid)
);
CREATE INDEX problem_1 ON problem (source,object,objectid);
CREATE INDEX problem_2 ON problem (r_clock);
CREATE INDEX problem_3 ON problem (r_eventid);
CREATE TABLE problem_tag (
	problemtagid             bigint                                    NOT NULL,
	eventid                  bigint                                    NOT NULL REFERENCES problem (eventid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (problemtagid)
);
CREATE INDEX problem_tag_1 ON problem_tag (eventid,tag,value);
CREATE TABLE tag_filter (
	tag_filterid             bigint                                    NOT NULL,
	usrgrpid                 bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid) ON DELETE CASCADE,
	groupid                  bigint                                    NOT NULL REFERENCES hstgrp (groupid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (tag_filterid)
);
CREATE TABLE event_recovery (
	eventid                  bigint                                    NOT NULL REFERENCES events (eventid) ON DELETE CASCADE,
	r_eventid                bigint                                    NOT NULL REFERENCES events (eventid) ON DELETE CASCADE,
	c_eventid                bigint                                    NULL REFERENCES events (eventid) ON DELETE CASCADE,
	correlationid            bigint                                    NULL,
	userid                   bigint                                    NULL,
	PRIMARY KEY (eventid)
);
CREATE INDEX event_recovery_1 ON event_recovery (r_eventid);
CREATE INDEX event_recovery_2 ON event_recovery (c_eventid);
CREATE TABLE correlation (
	correlationid            bigint                                    NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	description              text            DEFAULT ''                NOT NULL,
	evaltype                 integer         DEFAULT '0'               NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	formula                  varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (correlationid)
);
CREATE INDEX correlation_1 ON correlation (status);
CREATE UNIQUE INDEX correlation_2 ON correlation (name);
CREATE TABLE corr_condition (
	corr_conditionid         bigint                                    NOT NULL,
	correlationid            bigint                                    NOT NULL REFERENCES correlation (correlationid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (corr_conditionid)
);
CREATE INDEX corr_condition_1 ON corr_condition (correlationid);
CREATE TABLE corr_condition_tag (
	corr_conditionid         bigint                                    NOT NULL REFERENCES corr_condition (corr_conditionid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (corr_conditionid)
);
CREATE TABLE corr_condition_group (
	corr_conditionid         bigint                                    NOT NULL REFERENCES corr_condition (corr_conditionid) ON DELETE CASCADE,
	operator                 integer         DEFAULT '0'               NOT NULL,
	groupid                  bigint                                    NOT NULL REFERENCES hstgrp (groupid),
	PRIMARY KEY (corr_conditionid)
);
CREATE INDEX corr_condition_group_1 ON corr_condition_group (groupid);
CREATE TABLE corr_condition_tagpair (
	corr_conditionid         bigint                                    NOT NULL REFERENCES corr_condition (corr_conditionid) ON DELETE CASCADE,
	oldtag                   varchar(255)    DEFAULT ''                NOT NULL,
	newtag                   varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (corr_conditionid)
);
CREATE TABLE corr_condition_tagvalue (
	corr_conditionid         bigint                                    NOT NULL REFERENCES corr_condition (corr_conditionid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	operator                 integer         DEFAULT '0'               NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (corr_conditionid)
);
CREATE TABLE corr_operation (
	corr_operationid         bigint                                    NOT NULL,
	correlationid            bigint                                    NOT NULL REFERENCES correlation (correlationid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (corr_operationid)
);
CREATE INDEX corr_operation_1 ON corr_operation (correlationid);
CREATE TABLE task (
	taskid                   bigint                                    NOT NULL,
	type                     integer                                   NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	clock                    integer         DEFAULT '0'               NOT NULL,
	ttl                      integer         DEFAULT '0'               NOT NULL,
	proxy_hostid             bigint                                    NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	PRIMARY KEY (taskid)
);
CREATE INDEX task_1 ON task (status,proxy_hostid);
CREATE TABLE task_close_problem (
	taskid                   bigint                                    NOT NULL REFERENCES task (taskid) ON DELETE CASCADE,
	acknowledgeid            bigint                                    NOT NULL,
	PRIMARY KEY (taskid)
);
CREATE TABLE item_preproc (
	item_preprocid           bigint                                    NOT NULL,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	step                     integer         DEFAULT '0'               NOT NULL,
	type                     integer         DEFAULT '0'               NOT NULL,
	params                   text            DEFAULT ''                NOT NULL,
	error_handler            integer         DEFAULT '0'               NOT NULL,
	error_handler_params     varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (item_preprocid)
);
CREATE INDEX item_preproc_1 ON item_preproc (itemid,step);
CREATE TABLE task_remote_command (
	taskid                   bigint                                    NOT NULL REFERENCES task (taskid) ON DELETE CASCADE,
	command_type             integer         DEFAULT '0'               NOT NULL,
	execute_on               integer         DEFAULT '0'               NOT NULL,
	port                     integer         DEFAULT '0'               NOT NULL,
	authtype                 integer         DEFAULT '0'               NOT NULL,
	username                 varchar(64)     DEFAULT ''                NOT NULL,
	password                 varchar(64)     DEFAULT ''                NOT NULL,
	publickey                varchar(64)     DEFAULT ''                NOT NULL,
	privatekey               varchar(64)     DEFAULT ''                NOT NULL,
	command                  text            DEFAULT ''                NOT NULL,
	alertid                  bigint                                    NULL,
	parent_taskid            bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL,
	PRIMARY KEY (taskid)
);
CREATE TABLE task_remote_command_result (
	taskid                   bigint                                    NOT NULL REFERENCES task (taskid) ON DELETE CASCADE,
	status                   integer         DEFAULT '0'               NOT NULL,
	parent_taskid            bigint                                    NOT NULL,
	info                     text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (taskid)
);
CREATE TABLE task_data (
	taskid                   bigint                                    NOT NULL REFERENCES task (taskid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	data                     text            DEFAULT ''                NOT NULL,
	parent_taskid            bigint                                    NOT NULL,
	PRIMARY KEY (taskid)
);
CREATE TABLE task_result (
	taskid                   bigint                                    NOT NULL REFERENCES task (taskid) ON DELETE CASCADE,
	status                   integer         DEFAULT '0'               NOT NULL,
	parent_taskid            bigint                                    NOT NULL,
	info                     text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (taskid)
);
CREATE INDEX task_result_1 ON task_result (parent_taskid);
CREATE TABLE task_acknowledge (
	taskid                   bigint                                    NOT NULL REFERENCES task (taskid) ON DELETE CASCADE,
	acknowledgeid            bigint                                    NOT NULL,
	PRIMARY KEY (taskid)
);
CREATE TABLE sysmap_shape (
	sysmap_shapeid           bigint                                    NOT NULL,
	sysmapid                 bigint                                    NOT NULL REFERENCES sysmaps (sysmapid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	x                        integer         DEFAULT '0'               NOT NULL,
	y                        integer         DEFAULT '0'               NOT NULL,
	width                    integer         DEFAULT '200'             NOT NULL,
	height                   integer         DEFAULT '200'             NOT NULL,
	text                     text            DEFAULT ''                NOT NULL,
	font                     integer         DEFAULT '9'               NOT NULL,
	font_size                integer         DEFAULT '11'              NOT NULL,
	font_color               varchar(6)      DEFAULT '000000'          NOT NULL,
	text_halign              integer         DEFAULT '0'               NOT NULL,
	text_valign              integer         DEFAULT '0'               NOT NULL,
	border_type              integer         DEFAULT '0'               NOT NULL,
	border_width             integer         DEFAULT '1'               NOT NULL,
	border_color             varchar(6)      DEFAULT '000000'          NOT NULL,
	background_color         varchar(6)      DEFAULT ''                NOT NULL,
	zindex                   integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (sysmap_shapeid)
);
CREATE INDEX sysmap_shape_1 ON sysmap_shape (sysmapid);
CREATE TABLE sysmap_element_trigger (
	selement_triggerid       bigint                                    NOT NULL,
	selementid               bigint                                    NOT NULL REFERENCES sysmaps_elements (selementid) ON DELETE CASCADE,
	triggerid                bigint                                    NOT NULL REFERENCES triggers (triggerid) ON DELETE CASCADE,
	PRIMARY KEY (selement_triggerid)
);
CREATE UNIQUE INDEX sysmap_element_trigger_1 ON sysmap_element_trigger (selementid,triggerid);
CREATE TABLE httptest_field (
	httptest_fieldid         bigint                                    NOT NULL,
	httptestid               bigint                                    NOT NULL REFERENCES httptest (httptestid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	value                    text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (httptest_fieldid)
);
CREATE INDEX httptest_field_1 ON httptest_field (httptestid);
CREATE TABLE httpstep_field (
	httpstep_fieldid         bigint                                    NOT NULL,
	httpstepid               bigint                                    NOT NULL REFERENCES httpstep (httpstepid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	value                    text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (httpstep_fieldid)
);
CREATE INDEX httpstep_field_1 ON httpstep_field (httpstepid);
CREATE TABLE dashboard (
	dashboardid              bigint                                    NOT NULL,
	name                     varchar(255)                              NOT NULL,
	userid                   bigint                                    NOT NULL REFERENCES users (userid),
	private                  integer         DEFAULT '1'               NOT NULL,
	PRIMARY KEY (dashboardid)
);
CREATE TABLE dashboard_user (
	dashboard_userid         bigint                                    NOT NULL,
	dashboardid              bigint                                    NOT NULL REFERENCES dashboard (dashboardid) ON DELETE CASCADE,
	userid                   bigint                                    NOT NULL REFERENCES users (userid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (dashboard_userid)
);
CREATE UNIQUE INDEX dashboard_user_1 ON dashboard_user (dashboardid,userid);
CREATE TABLE dashboard_usrgrp (
	dashboard_usrgrpid       bigint                                    NOT NULL,
	dashboardid              bigint                                    NOT NULL REFERENCES dashboard (dashboardid) ON DELETE CASCADE,
	usrgrpid                 bigint                                    NOT NULL REFERENCES usrgrp (usrgrpid) ON DELETE CASCADE,
	permission               integer         DEFAULT '2'               NOT NULL,
	PRIMARY KEY (dashboard_usrgrpid)
);
CREATE UNIQUE INDEX dashboard_usrgrp_1 ON dashboard_usrgrp (dashboardid,usrgrpid);
CREATE TABLE widget (
	widgetid                 bigint                                    NOT NULL,
	dashboardid              bigint                                    NOT NULL REFERENCES dashboard (dashboardid) ON DELETE CASCADE,
	type                     varchar(255)    DEFAULT ''                NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	x                        integer         DEFAULT '0'               NOT NULL,
	y                        integer         DEFAULT '0'               NOT NULL,
	width                    integer         DEFAULT '1'               NOT NULL,
	height                   integer         DEFAULT '2'               NOT NULL,
	view_mode                integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (widgetid)
);
CREATE INDEX widget_1 ON widget (dashboardid);
CREATE TABLE widget_field (
	widget_fieldid           bigint                                    NOT NULL,
	widgetid                 bigint                                    NOT NULL REFERENCES widget (widgetid) ON DELETE CASCADE,
	type                     integer         DEFAULT '0'               NOT NULL,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	value_int                integer         DEFAULT '0'               NOT NULL,
	value_str                varchar(255)    DEFAULT ''                NOT NULL,
	value_groupid            bigint                                    NULL REFERENCES hstgrp (groupid) ON DELETE CASCADE,
	value_hostid             bigint                                    NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	value_itemid             bigint                                    NULL REFERENCES items (itemid) ON DELETE CASCADE,
	value_graphid            bigint                                    NULL REFERENCES graphs (graphid) ON DELETE CASCADE,
	value_sysmapid           bigint                                    NULL REFERENCES sysmaps (sysmapid) ON DELETE CASCADE,
	PRIMARY KEY (widget_fieldid)
);
CREATE INDEX widget_field_1 ON widget_field (widgetid);
CREATE INDEX widget_field_2 ON widget_field (value_groupid);
CREATE INDEX widget_field_3 ON widget_field (value_hostid);
CREATE INDEX widget_field_4 ON widget_field (value_itemid);
CREATE INDEX widget_field_5 ON widget_field (value_graphid);
CREATE INDEX widget_field_6 ON widget_field (value_sysmapid);
CREATE TABLE task_check_now (
	taskid                   bigint                                    NOT NULL REFERENCES task (taskid) ON DELETE CASCADE,
	itemid                   bigint                                    NOT NULL,
	PRIMARY KEY (taskid)
);
CREATE TABLE event_suppress (
	event_suppressid         bigint                                    NOT NULL,
	eventid                  bigint                                    NOT NULL REFERENCES events (eventid) ON DELETE CASCADE,
	maintenanceid            bigint                                    NULL REFERENCES maintenances (maintenanceid) ON DELETE CASCADE,
	suppress_until           integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (event_suppressid)
);
CREATE UNIQUE INDEX event_suppress_1 ON event_suppress (eventid,maintenanceid);
CREATE INDEX event_suppress_2 ON event_suppress (suppress_until);
CREATE INDEX event_suppress_3 ON event_suppress (maintenanceid);
CREATE TABLE maintenance_tag (
	maintenancetagid         bigint                                    NOT NULL,
	maintenanceid            bigint                                    NOT NULL REFERENCES maintenances (maintenanceid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	operator                 integer         DEFAULT '2'               NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (maintenancetagid)
);
CREATE INDEX maintenance_tag_1 ON maintenance_tag (maintenanceid);
CREATE TABLE lld_macro_path (
	lld_macro_pathid         bigint                                    NOT NULL,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	lld_macro                varchar(255)    DEFAULT ''                NOT NULL,
	path                     varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (lld_macro_pathid)
);
CREATE UNIQUE INDEX lld_macro_path_1 ON lld_macro_path (itemid,lld_macro);
CREATE TABLE host_tag (
	hosttagid                bigint                                    NOT NULL,
	hostid                   bigint                                    NOT NULL REFERENCES hosts (hostid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (hosttagid)
);
CREATE INDEX host_tag_1 ON host_tag (hostid);
CREATE TABLE config_autoreg_tls (
	autoreg_tlsid            bigint                                    NOT NULL,
	tls_psk_identity         varchar(128)    DEFAULT ''                NOT NULL,
	tls_psk                  varchar(512)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (autoreg_tlsid)
);
CREATE UNIQUE INDEX config_autoreg_tls_1 ON config_autoreg_tls (tls_psk_identity);
CREATE TABLE module (
	moduleid                 bigint                                    NOT NULL,
	id                       varchar(255)    DEFAULT ''                NOT NULL,
	relative_path            varchar(255)    DEFAULT ''                NOT NULL,
	status                   integer         DEFAULT '0'               NOT NULL,
	config                   text            DEFAULT ''                NOT NULL,
	PRIMARY KEY (moduleid)
);
CREATE TABLE interface_snmp (
	interfaceid              bigint                                    NOT NULL REFERENCES interface (interfaceid) ON DELETE CASCADE,
	version                  integer         DEFAULT '2'               NOT NULL,
	bulk                     integer         DEFAULT '1'               NOT NULL,
	community                varchar(64)     DEFAULT ''                NOT NULL,
	securityname             varchar(64)     DEFAULT ''                NOT NULL,
	securitylevel            integer         DEFAULT '0'               NOT NULL,
	authpassphrase           varchar(64)     DEFAULT ''                NOT NULL,
	privpassphrase           varchar(64)     DEFAULT ''                NOT NULL,
	authprotocol             integer         DEFAULT '0'               NOT NULL,
	privprotocol             integer         DEFAULT '0'               NOT NULL,
	contextname              varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (interfaceid)
);
CREATE TABLE lld_override (
	lld_overrideid           bigint                                    NOT NULL,
	itemid                   bigint                                    NOT NULL REFERENCES items (itemid) ON DELETE CASCADE,
	name                     varchar(255)    DEFAULT ''                NOT NULL,
	step                     integer         DEFAULT '0'               NOT NULL,
	evaltype                 integer         DEFAULT '0'               NOT NULL,
	formula                  varchar(255)    DEFAULT ''                NOT NULL,
	stop                     integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (lld_overrideid)
);
CREATE UNIQUE INDEX lld_override_1 ON lld_override (itemid,name);
CREATE TABLE lld_override_condition (
	lld_override_conditionid bigint                                    NOT NULL,
	lld_overrideid           bigint                                    NOT NULL REFERENCES lld_override (lld_overrideid) ON DELETE CASCADE,
	operator                 integer         DEFAULT '8'               NOT NULL,
	macro                    varchar(64)     DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (lld_override_conditionid)
);
CREATE INDEX lld_override_condition_1 ON lld_override_condition (lld_overrideid);
CREATE TABLE lld_override_operation (
	lld_override_operationid bigint                                    NOT NULL,
	lld_overrideid           bigint                                    NOT NULL REFERENCES lld_override (lld_overrideid) ON DELETE CASCADE,
	operationobject          integer         DEFAULT '0'               NOT NULL,
	operator                 integer         DEFAULT '0'               NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE INDEX lld_override_operation_1 ON lld_override_operation (lld_overrideid);
CREATE TABLE lld_override_opstatus (
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	status                   integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE TABLE lld_override_opdiscover (
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	discover                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE TABLE lld_override_opperiod (
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	delay                    varchar(1024)   DEFAULT '0'               NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE TABLE lld_override_ophistory (
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	history                  varchar(255)    DEFAULT '90d'             NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE TABLE lld_override_optrends (
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	trends                   varchar(255)    DEFAULT '365d'            NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE TABLE lld_override_opseverity (
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	severity                 integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE TABLE lld_override_optag (
	lld_override_optagid     bigint                                    NOT NULL,
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	tag                      varchar(255)    DEFAULT ''                NOT NULL,
	value                    varchar(255)    DEFAULT ''                NOT NULL,
	PRIMARY KEY (lld_override_optagid)
);
CREATE INDEX lld_override_optag_1 ON lld_override_optag (lld_override_operationid);
CREATE TABLE lld_override_optemplate (
	lld_override_optemplateid bigint                                    NOT NULL,
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	templateid               bigint                                    NOT NULL REFERENCES hosts (hostid),
	PRIMARY KEY (lld_override_optemplateid)
);
CREATE UNIQUE INDEX lld_override_optemplate_1 ON lld_override_optemplate (lld_override_operationid,templateid);
CREATE INDEX lld_override_optemplate_2 ON lld_override_optemplate (templateid);
CREATE TABLE lld_override_opinventory (
	lld_override_operationid bigint                                    NOT NULL REFERENCES lld_override_operation (lld_override_operationid) ON DELETE CASCADE,
	inventory_mode           integer         DEFAULT '0'               NOT NULL,
	PRIMARY KEY (lld_override_operationid)
);
CREATE TABLE dbversion (
	mandatory                integer         DEFAULT '0'               NOT NULL,
	optional                 integer         DEFAULT '0'               NOT NULL
);
INSERT INTO dbversion VALUES ('5000000','5000002');
