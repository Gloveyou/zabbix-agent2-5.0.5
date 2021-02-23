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

const keyASMDiskGroupsDiscovery = "oracle.diskgroups.discovery"

const ASMDiskGroupsMaxParams = 0

func ASMDiskGroupsDiscovery(ctx context.Context, conn OraClient, params []string) (interface{}, error) {
	// var lld string

	if len(params) > ASMDiskGroupsMaxParams {
		return nil, zbxerr.ErrorTooManyParameters
	}

	rows, err := conn.Query(ctx, `
		SELECT
			NAME
		FROM
			V$ASM_DISKGROUP
	`)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}
	defer rows.Close()

	var dgname string

	var res []map[string]string

	for rows.Next() {
		err = rows.Scan(&dgname)
		if err != nil {
			return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
		}

		res = append(res, map[string]string{
			"{#DGNAME}": dgname,
		})
	}

	if len(res) == 0 {
		res = []map[string]string{}
	}

	// Manually marshall JSON due to get around the problem with VARCHAR2 limit (ORA-40478, maximum: 4000)
	jsonRes, err := json.Marshal(res)
	if err != nil {
		return nil, zbxerr.ErrorCannotMarshalJSON.Wrap(err)
	}

	return string(jsonRes), nil
}
