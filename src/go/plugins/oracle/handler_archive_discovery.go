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

const keyArchiveDiscovery = "oracle.archive.discovery"

const archiveDiscoveryMaxParams = 0

func archiveDiscoveryHandler(ctx context.Context, conn OraClient, params []string) (interface{}, error) {
	// var lld string

	if len(params) > archiveDiscoveryMaxParams {
		return nil, zbxerr.ErrorTooManyParameters
	}

	rows, err := conn.Query(ctx, `
		SELECT
			d.DEST_NAME
		FROM
			V$ARCHIVE_DEST d,
			V$DATABASE db
		WHERE
			d.STATUS != 'INACTIVE'
			AND db.LOG_MODE = 'ARCHIVELOG'
	`)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}
	defer rows.Close()

	var dest_name string

	var res []map[string]string

	for rows.Next() {
		err = rows.Scan(&dest_name)
		if err != nil {
			return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
		}

		res = append(res, map[string]string{
			"{#DEST_NAME}": dest_name,
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
