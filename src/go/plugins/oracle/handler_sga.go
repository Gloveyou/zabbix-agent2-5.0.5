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

const keySGA = "oracle.sga.stats"

const SGAMaxParams = 0

func SGAHandler(ctx context.Context, conn OraClient, params []string) (interface{}, error) {
	// var SGA string

	if len(params) > SGAMaxParams {
		return nil, zbxerr.ErrorTooManyParameters
	}

	rows, err := conn.Query(ctx, `
		SELECT
			v.POOL, v.BYTES
		FROM
			(
			SELECT
				POOL, 
				SUM(BYTES) AS BYTES
			FROM
				(
				SELECT
					LOWER(REPLACE(POOL, ' ', '_')) AS POOL,
					SUM(BYTES) AS BYTES
				FROM
					V$SGASTAT
				WHERE
					POOL IN ('java pool', 'large pool')
				GROUP BY
					POOL
					
				UNION
				
				SELECT
					'shared_pool',
					SUM(BYTES)
				FROM
					V$SGASTAT
				WHERE
					POOL = 'shared pool'
					AND NAME NOT IN ('library cache', 'dictionary cache', 'free memory', 'sql area')
					
				UNION
				
				SELECT
					NAME,
					BYTES
				FROM
					V$SGASTAT
				WHERE
					POOL IS NULL
					AND NAME IN ('log_buffer', 'fixed_sga')
					
				UNION
				
				SELECT
					'buffer_cache',
					SUM(BYTES)
				FROM
					V$SGASTAT
				WHERE
					POOL IS NULL
					AND NAME IN ('buffer_cache', 'db_block_buffers')
					
				UNION
				
				SELECT
					DISTINCT *
				FROM
					TABLE(sys.ODCIVARCHAR2LIST('buffer_cache', 'fixed_sga', 'java_pool', 'large_pool', 'log_buffer', 'shared_pool')), 
					TABLE(sys.ODCINUMBERLIST(0, 0, 0, 0, 0, 0))	
				)
			GROUP BY
				POOL
			) v
	`)
	if err != nil {
		return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
	}
	defer rows.Close()

	var metric, value string

	res := make(map[string]string)

	for rows.Next() {
		err = rows.Scan(&metric, &value)
		if err != nil {
			return nil, zbxerr.ErrorCannotFetchData.Wrap(err)
		}

		res[metric] = value
	}

	// Manually marshall JSON due to get around the problem with VARCHAR2 limit (ORA-40478, maximum: 4000)
	jsonRes, err := json.Marshal(res)
	if err != nil {
		return nil, zbxerr.ErrorCannotMarshalJSON.Wrap(err)
	}

	return string(jsonRes), nil
}
