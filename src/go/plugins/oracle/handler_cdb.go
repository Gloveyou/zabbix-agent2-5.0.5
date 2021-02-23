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

const keyCDB = "oracle.cdb.info"

const CDBMaxParams = 0

func CDBHandler(ctx context.Context, conn OraClient, params []string) (interface{}, error) {
	// var CDBInfo string

	if len(params) > CDBMaxParams {
		return nil, zbxerr.ErrorTooManyParameters
	}

	row, err := conn.QueryRow(ctx, `
   		SELECT
			NAME,
			DECODE(OPEN_MODE, 
				'MOUNTED',              1, 
				'READ ONLY',            2, 
				'READ WRITE',           3, 
				'READ ONLY WITH APPLY', 4, 
				'MIGRATE', 5, 
			0),
			DECODE(DATABASE_ROLE,
				'SNAPSHOT STANDBY', 1, 
				'LOGICAL STANDBY',  2, 
				'PHYSICAL STANDBY', 3, 
				'PRIMARY',          4, 
				'FAR SYNC', 5, 
			0),
			DECODE(FORCE_LOGGING, 
				'YES', 1, 
				'NO' , 0, 
			0),
			DECODE(LOG_MODE, 
				'NOARCHIVELOG', 0,
				'ARCHIVELOG', 1, 
				'MANUAL', 2,
			0)	
		FROM
			V$DATABASE
	`)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}

	var name, open_mode, role, force_logging, log_mode string

	res := make(map[string]map[string]string)
	
	err = row.Scan(&name, &open_mode, &role, &force_logging, &log_mode)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}

	res[name] = make(map[string]string)
	res[name]["open_mode"] = open_mode
	res[name]["role"] = role
	res[name]["force_logging"] = force_logging
	res[name]["log_mode"] = log_mode

	// Manually marshall JSON due to get around the problem with VARCHAR2 limit (ORA-40478, maximum: 4000)
	jsonRes, err := json.Marshal(res)
	if err != nil {
		return nil, zbxerr.ErrorCannotMarshalJSON.Wrap(err)
	}

	return string(jsonRes), nil
}
