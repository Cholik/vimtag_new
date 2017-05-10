/*!
\file       code_gen.h
\brief      code gen
----history----
\author     chengzhiyong
\date       2011-11-21
\version    0.01
\desc       create

$Author: chengzhiyong $
*/
#if !defined(__code_gen_h__)
#define __code_gen_h__

#if defined(__cplusplus)
extern "C" {
#endif

#define code_gen_err_invalid_param          -1
#define code_gen_err_malloc_failed          -2
#define code_gen_err_open_file_failed       -3

long code_gen_build_makefile(char *file);
long code_gen_build_makefile_native(char *file, char *ldflags);
long code_gen_build_makefile_ios(char *file);
long code_gen_build_makefile_darwin(char *file);
long code_gen_build_makefile_hisi_linux(char *file);
long code_gen_build_makefile_hisiv100_linux(char *file);
long code_gen_build_makefile_hi3518x_linux(char *file);
long code_gen_build_makefile_faraday_linux(char *file);
long code_gen_build_makefile_gm828x_linux(char *file);
long code_gen_build_makefile_gm8136_linux(char *file);
long code_gen_build_makefile_ti_linux(char *file);
long code_gen_build_makefile_fh8620_rtthread(char *file);
long code_gen_build_makefile_fh8810_linux(char *file);

long code_gen_build_dsp(char *file, char *project_name,
                        unsigned long cfile_counts, struct len_str *cfiles, 
                        unsigned long hfile_counts, struct len_str *hfiles);

long code_gen_build_vcxproj(char *file, char *project_name,
                            unsigned long cfile_counts, struct len_str *cfiles, 
                            unsigned long hfile_counts, struct len_str *hfiles);

long code_gen_build_vcxproj_filters(char *file, char *project_name,
                                    unsigned long cfile_counts, struct len_str *cfiles, 
                                    unsigned long hfile_counts, struct len_str *hfiles);

struct code_gen_project *code_gen_project_create(char *name, char *dir/* can be NULL */, char *ldflags/* can be NULL */);
long code_gen_project_destroy(struct code_gen_project *prj);
long code_gen_project_add(struct code_gen_project *prj, char *type, char *file);
long code_gen_project_build(struct code_gen_project *prj);

long code_gen_project_update(char *dir/* can be NULL, if NULL cur dir */,
                             char *project_name/* can be NULL, if null use this folder's name as project_name */);

long code_gen_build_lang_strings_js(struct json_object* root, char *path);
long code_gen_build_lang_strings_ios(struct json_object* root, char *path);
long code_gen_build_lang_strings_android(struct json_object* root, char *path);
long code_gen_build_lang_strings(char *file, char *path);

/*!
func    code_gen_build_factory
\brief  build the base c code of the special factory
\param  name[in]                the factory name, invalid char will be convert to '_'
\param  factory_file[in]        the factory transaction definition file, input file
\param  save_dir[in]            the dir of the output files, must exists
                                if null save to current dir
\return run result
        #0                      succeed
        #other                  error code
*/
long code_gen_build_factory(char *name, char *factory_file, char *save_dir);

/*!
func    code_gen_build_component
\brief  build the base c code of the special component
\param  name[in]                project name
\param  name[in]                the component name, invalid char will be convert to '_'
\param  trans_file[in]          the component transaction definition file, input file
\param  conf_file[in]           the config file name, output file
\param  save_dir[in]            the dir of the output files, must exists
                                if null save to current dir
\return run result
        #0                      succeed
        #other                  error code
*/
long code_gen_build_component(char *project_name, char *name, char *trans_file, char *conf_def, char *save_dir);

/*!
func    code_gen_tool_entry
\brief  same interface as main function, code_gen tool
\param  argc[in]                argc counts
\param  argv[in]                argv list
\return run result
        #0                      succeed
        #other                  error code
*/
long code_gen_tool_entry(unsigned long argc, char *argv[]);

#if defined(__cplusplus)
}
#endif

#endif /* !defined(__code_gen_h__) */

