/*
\file		table.h
\brief		table unit, compatible ipc(share-memory);
            dealwith table in ram and can dump into disk
			columns(fields) and it's length can be unlimited, all data be save as string.
 ----history----
\author     chengzhiyong
\date       2007-05-13
\version    0.01
\desc       create

$Author: chengzhiyong $
$Id: table.h,v 1.2 2008-05-31 05:32:39 chengzhiyong Exp $
*/
#if !defined(__table_h__)
#   define  __table_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct table;

/* this file copy from comp/db/inc/db-def.h */
typedef struct tbl_field
{
	unsigned long   id;	/* field id */ 
	struct {unsigned long len; char* data;}	value;	/* value */ 
}_tbl_field;

typedef struct tbl_condt
{
	unsigned long       opt;	/* the operate */ 
	struct tbl_field	field;	/* field */ 
}_tbl_condt;

typedef struct tbl_get_req
{
	struct
	{
		unsigned long       counts;	/* fields counts */
		unsigned long       *data;	/* fields data */
	}fields;	/* output field id list, NULL or 0xffffffff means all */ 
	struct
	{
		unsigned long       counts;	/* record_ids counts */
		unsigned long       *data;	/* record_ids data */
	}record_ids;	/* record ids */ 
	struct
	{
		unsigned long       counts;	/* condt counts */
		struct tbl_condt    *data;	/* condt data */
	}condt;	/* condition */ 
	struct
	{
		unsigned long       counts;	/* order_by counts */
		unsigned long       *data;	/* order_by data */
	}order_by;	/* order field id list */ 
	int	start;	/* start record, if < 0 will be distinct order */ 
	unsigned long           counts;	/* max output counts */ 
}_tbl_get_req;

typedef struct tbl_get_ack
{
	int	result;	/* get result */ 
	int	size;	/* ack size include self */ 
	int	total_counts;	/* total counts */ 
	int	start;	/* start record index */ 
	int	end;	/* end record index */ 
	struct
	{
		unsigned	counts;	/* records counts */
	
		struct 
		{
			struct
			{
				unsigned	counts;	/* fields counts */
				struct tbl_field*	data;	/* fields data */
			}fields;	/* field list */ 
		}*	data;	/* records data */
	}records;	/* record list */ 
}_tbl_get_ack;

typedef struct tbl_add_req
{
	struct
	{
		unsigned	counts;	/* fileds counts */
		struct tbl_field*	data;	/* fileds data */
	}fileds;	/* fields list */ 
}_tbl_add_req;

typedef struct tbl_add_ack
{
	int	result;	/* add result */ 
	int	record_id;	/* record id */ 
}_tbl_add_ack;


/*!
func    tbl_sizeof
\brief  get the size of the table
\param  max_row_counts[in]      max row(record) counts
\param  col_counts[in]          column(field) counts in a record, near value,
                                can be set as average fields counts in a record
\pram   row_size[in]            row(record) size, near value to caculate the space size that data need
\return the size of the table
*/
unsigned long tbl_sizeof(unsigned long max_row_counts, unsigned long col_counts, unsigned long row_size);

/*!
func    tbl_init
\brief  init table, if load from filemapping, do not need init
\param  tbl[in]                 the table object buffer
\param  max_row_counts[in]      max row(record) counts, if 0 will be dealwith as default:1000000
\param  col_counts[in]          column(field) counts in a record, near value,
                                can be set as average fields counts in a record
                                if 0 will be dealwith as default:32
\pram   row_size[in]            row(record) size, near value to caculate the space size that data need
                                if 0 will be dealwith as default:1024
\return init result
        #<0                     error code
        #other                  the size
*/
long tbl_init(struct table *tbl,
              unsigned long max_row_counts,  /* default:1000000 */
              unsigned long col_counts,      /* default:32 */
              unsigned long row_size);       /* default:1024 */

/*!
func    tbl_check
\brief  check table object data is correct
\param  tbl[in]                 the table object buffer
\param  data_size[in]           the data size of table object
\return check result
        #0                      succeed, valid table
        #other                  error code
*/
long tbl_check(struct table *tbl, unsigned long data_size);

/*!
func    tbl_get_data_size
\brief  get the data size of the table
\param  tbl[in]                 the table object buffer
\return the size of the table
        #<0                     error code
        #other                  the size
*/
long tbl_get_data_size(struct table *tbl);

/*!
func    tbl_add
\brief  add a row into table
\param  tbl[in]                 the table object
\param  record_id[in]           the record id, if 0 will create new one.
\param  counts[in]              the counts of the fields
\param  fields[in]              the fields
\return add result
        #>0                     record id
        #<0                     error code
        #0                      will not happen
*/
long tbl_add(struct table*      tbl,
             unsigned long      record_id,
             unsigned long      counts,
             struct tbl_field*  fields);

/*!
func    tbl_get
\brief  query data from table by special condition
\param  tbl[in]                 the table object
\param  req[in]                 the request
\param  max_ack_size[in]        the max size of the output ack
\param  ack[in]                 the ack
\return get result
        #0                      succeed
        #other                  error code
*/
long tbl_get(struct table*          tbl,
             struct tbl_get_req*    req,
             unsigned long          max_ack_size,
             struct tbl_get_ack*    ack);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__table_h__) */
