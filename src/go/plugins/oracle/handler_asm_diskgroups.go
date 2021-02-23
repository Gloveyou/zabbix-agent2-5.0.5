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

const keyASMDiskGroups = "oracle.diskgroups.stats"

const ASMDiskGroupsInfoMaxParams = 0

func ASMDiskGroupsHandler(ctx context.Context, conn OraClient, params []string) (interface{}, error) {
	// var diskGroups string

	if len(params) > ASMDiskGroupsInfoMaxParams {
		return nil, zbxerr.ErrorTooManyParameters
	}

	rows, err := conn.Query(ctx, `
		SELECT
			NAME,
			ROUND(TOTAL_MB / DECODE(TYPE, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3) * 1024 * 1024),
			ROUND(USABLE_FILE_MB * 1024 * 1024), 
			ROUND(100 - (USABLE_FILE_MB / (TOTAL_MB / 
			DECODE(TYPE, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3))) * 100, 2)
         FROM 
         	V$ASM_DISKGROUP
	`)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}
	defer rows.Close()

	var name, total_bytes, free_bytes, used_pct string

	res := make(map[string]map[string]string)

	for rows.Next() {
		err = rows.Scan(&name, &total_bytes, &free_bytes, &used_pct)
		if err != nil {
			return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
		}

		res[name] = make(map[string]string)
		res[name]["total_bytes"] = total_bytes
		res[name]["free_bytes"] = free_bytes
		res[name]["used_pct"] = used_pct
	}

	// Manually marshall JSON due to get around the problem with VARCHAR2 limit (ORA-40478, maximum: 4000)
	jsonRes, err := json.Marshal(res)
	if err != nil {
		return nil, zbxerr.ErrorCannotMarshalJSON.Wrap(err)
	}

	return string(jsonRes), nil

	// if diskGroups == "" {
	// 	diskGroups = "[]"
	// }

	// return diskGroups, nil
}
