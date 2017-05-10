	/*
\file       dump_file.h
\brief

----history----
\author     zhengxianwei
\date       2009Äê03ÔÂ16ÈÕ
\version    0.01
\desc       create
*/

#if defined(__cplusplus)
extern "C" {
#endif/* defined(__cplusplus) */

#ifndef  __dump_file_h___
#define  __dump_file_h___

#define     DUMP_COMM_HEADER(f)                     \
    fprintf (f, "/*!\n"                             \
/* s1 */        "\\file         %s.c\n"             \
                "\\brief\n"                         \
                "\n"                                \
                " ----history---- \n"               \
                "\\author       auto-gen\n"         \
/* s2 */        "\\date         %s\n"               \
/* s3 */        "\\version      %s\n"               \
                "\\desc         create\n"           \
                "*/\n",                             \
                in->xsl_filename.data,              \
                (char *)mtime2s (0),                 \
                "0.01")

#define     DUMP_INCLUDE_FILE(f)                    \
    fprintf (f, "#include\t<stdio.h>\n"             \
                "#include\t<stdlib.h>\n"            \
                "#include\t<string.h>\n"            \
                "#include\t<time.h>\n")

#define     DUMP_DECLARE(f)                         \
    fprintf (f, "#if !defined(__pack_h)\n" \
                "typedef struct pack_str \n" \
                "{\n" \
                "\tunsigned\t\tlen;\n" \
                "\tchar *\t\tdata;\n" \
                "} _pack_str;\n" \
                "#endif \n\n" \
                "#define LPRINTF(str, len) \\\n"     \
                "\tdo\\\n" \
                "\t{\\\n" \
                "\t\ttmp = (len);\\\n" \
                "\t\tif (tmp > (size - index)) \\\n" \
                "\t\t\treturn (-1);\\\n" \
                "\\\n" \
                "\t\tif (tmp)\\\n" \
                "\t\t{\\\n" \
                "\t\t\tmemcpy (buf + index, str, tmp);\\\n" \
                "\t\t}\\\n" \
                "\t\tindex += tmp;\\\n" \
                "\t} while (0)\n\n" \
                "#define SLPRINTF(type,str,len)\\\n" \
                "\tdo \\\n" \
                "\t{ \\\n" \
                "\t\tif (len > (size - index))\\\n" \
                "\t\t\treturn (-1);\\\n"  \
                "\t\tindex += sprintf (buf + index, type, str);\\\n" \
                "\t} while (0)\n\n")

#define     DUMP_DLL_WINDOWS(f) \
    fprintf (f, "#if !defined(COMP_API)\n" \
                "#   if defined(_WIN32) && defined(_MSC_VER)\n" \
                "#       if defined(__cplusplus)\n" \
                "#           define COMP_API extern \"C\" __declspec(dllexport)\n" \
                "#       else\n" \
                "#           define COMP_API __declspec(dllexport)\n" \
                "#       endif\n" \
                "#   else\n" \
                "#   define COMP_API\n" \
                "#   endif\n" \
                "#endif\n" \
                "\n\n" \
                "#if defined(_WIN32) /* just for windows platform */\n" \
                "BOOL APIENTRY DllMain(HANDLE component, DWORD  reason, LPVOID reserved)\n" \
                "{\n" \
                "    switch(reason)\n" \
                "    {\n" \
                "        default: break; \n" \
                "    }\n" \
                "    return TRUE;\n" \
                "}\n" \
                "#endif\n");

#define     DUMP_NEWLINE(f)     fprintf (f, "\n")

#define	    DUMP_LBRACE_LN(f)                       \
    do                                              \
    {                                               \
        DUMP_INDENT (f,indent);                     \
        indent++;                                   \
        fprintf (f, "{\n");                         \
    } while (0)
#define     DUMP_RBRACE_LN(f)                       \
    do                                              \
    {                                               \
        indent--;                                   \
        DUMP_INDENT (f,indent);                     \
        fprintf (f, "}\n");                         \
    } while (0)

#define     DUMP_STATEMENT(f,instr)                 \
    do                                              \
    {                                               \
        DUMP_INDENT (f,indent);                     \
        fprintf (f, "%s", instr);                   \
    } while (0)

#define     DUMP_INDENT(f,count)                    \
    do                                              \
    {                                               \
        int i = 0;                                  \
        for (i = 0; i < count; i++)                 \
            fprintf (f, "\t");                      \
    } while (0)

#endif   /* ----- #ifndef __dump_file_h___  ----- */

#if defined(__cplusplus)
}
#endif/* defined(__cplusplus) */
