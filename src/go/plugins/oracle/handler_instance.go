/*
** Zabbix
** Copyright (C) 2001-2020 Zabbix SIA
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
**/

package oracle

import (
	"context"
	"encoding/json"

	"zabbix.com/pkg/zbxerr"
)

const keyInstance = "oracle.instance.info"

const instanceMaxParams = 0

func instanceHandler(ctx context.Context, conn OraClient, params []string) (interface{}, error) {
	// var instanceStats string

	if len(params) > instanceMaxParams {
		return nil, zbxerr.ErrorTooManyParameters
	}

	row, err := conn.QueryRow(ctx, `
		SELECT
			INSTANCE_NAME, 
			HOST_NAME, 
			VERSION,
			FLOOR((SYSDATE - STARTUP_TIME) * 60 * 60 * 24), 
			DECODE(STATUS, 'STARTED', 1, 'MOUNTED', 2, 'OPEN', 3, 'OPEN MIGRATE', 4, 0), 
			DECODE(ARCHIVER, 'STOPPED', 1, 'STARTED', 2, 'FAILED', 3, 0), 
			DECODE(INSTANCE_ROLE, 'PRIMARY_INSTANCE', 1, 'SECONDARY_INSTANCE', 2, 0)
		FROM
			V$INSTANCE
	`)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}

	var instance, hostname, version, uptime, status, archiver, role string

	res := make(map[string]string)
	
	err = row.Scan(&instance, &hostname, &version, &uptime, &status, &archiver, &role)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}

	res["instance"] = instance
	res["hostname"] = hostname
	res["version"] = version
	res["uptime"] = uptime
	res["status"] = status
	res["archiver"] = archiver
	res["role"] = role

	// Manually marshall JSON due to get around the problem with VARCHAR2 limit (ORA-40478, maximum: 4000)
	jsonRes, err := json.Marshal(res)
	if err != nil {
		return nil, zbxerr.ErrorCannotMarshalJSON.Wrap(err)
	}

	return string(jsonRes), nil
}
