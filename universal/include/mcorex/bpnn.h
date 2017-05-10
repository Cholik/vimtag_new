/*!
    (C)opyright chengzhiyong
    bp network unit

    \file       bpnn.h
    \brief      bp network unit

    ----history--------------------------------------------
    \author     chengzhiyong
    \date       2006-06-07
    \action     create
    \version    0.01

    History        
    $Author: chengzhiyong $
    $Id: bpnn.h,v 1.3 2008-08-05 01:19:10 chengzhiyong Exp $
*/
#if !defined(__bpnn_h__)
#define __bpnn_h__

#if defined(__cplusplus)
extern "C" {
#endif

struct bpnn;

/*! \brief create bp network */
struct bpnn *bp_create(unsigned long    in_counts,      /*!< [in] neurons counts in input layer */
                       unsigned long    out_counts,     /*!< [in] neurons counts in output layer */
                       unsigned long    hidden_counts   /*!< [in] neurons counts in hidden layer, if 0 use default */);
/*! \brief destroy bp network */
void bp_destroy(struct bpnn *nn                 /*!< [in] bp network */);

/*! \brief train network */
long bp_train(struct bpnn   *nn,                /*!< [in/out] bp network */
              double        *out_err            /*!< [out] output error*/);
/*! \brief calculate value by network */
long bp_calculate(struct bpnn   *nn             /*!< [in/out]bp network */);

/*! \brief load bp network from file */
struct bpnn *bp_load(char   *file_name          /*!< [in] bp network data filename */);
/*! \brief load bp network from file */
long bp_save(struct bpnn    *nn,                /*!< [in] bp network */
             char           *file_name          /*!< [in] bp network data filename */);

#if defined(__cplusplus)
}
#endif

#endif /* #if !defined(__bpnn_h__) */
