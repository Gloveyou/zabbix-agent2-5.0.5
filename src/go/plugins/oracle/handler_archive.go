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

const keyArchive = "oracle.archive.info"

const archiveMaxParams = 0

func archiveHandler(ctx context.Context, conn OraClient, params []string) (interface{}, error) {
	// var archiveLogs string

	if len(params) > archiveMaxParams {
		return nil, zbxerr.ErrorTooManyParameters
	}

	rows, err := conn.Query(ctx, `
		SELECT
			d.DEST_NAME,
			DECODE(d.STATUS, 'VALID', 3, 'DEFERRED', 2, 'ERROR', 1, 0),
			d.LOG_SEQUENCE,
			NVL(TO_CHAR(d.ERROR), ' ')	
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

	var dest_name, status, log_sequence, archive_error string

	res := make(map[string]map[string]string)

	for rows.Next() {
		err = rows.Scan(&dest_name, &status, &log_sequence, &archive_error)
		if err != nil {
			return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
		}

		res[dest_name] = make(map[string]string)
		res[dest_name]["status"] = status
		res[dest_name]["log_sequence"] = log_sequence
		res[dest_name]["archive_error"] = archive_error
	}

	// Manually marshall JSON due to get around the problem with VARCHAR2 limit (ORA-40478, maximum: 4000)
	jsonRes, err := json.Marshal(res)
	if err != nil {
		return nil, zbxerr.ErrorCannotMarshalJSON.Wrap(err)
	}

	return string(jsonRes), nil

	// if archiveLogs == "" {
	// 	archiveLogs = "[]"
	// }

	// return archiveLogs, nil
}
