/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     START = 258,
     END = 259,
     ON = 260,
     OFF = 261,
     TAKEOFF = 262,
     LAND = 263,
     TURN = 264,
     MOVE = 265,
     FLY = 266,
     SETSHIP = 267,
     SETSPACE = 268,
     ID = 269,
     NUM = 270,
     LPAREN = 271,
     RPAREN = 272,
     COLON = 273,
     SEMICOLON = 274
   };
#endif
/* Tokens.  */
#define START 258
#define END 259
#define ON 260
#define OFF 261
#define TAKEOFF 262
#define LAND 263
#define TURN 264
#define MOVE 265
#define FLY 266
#define SETSHIP 267
#define SETSPACE 268
#define ID 269
#define NUM 270
#define LPAREN 271
#define RPAREN 272
#define COLON 273
#define SEMICOLON 274




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 13 "tp3.y"
{
    char *str;
    int num;
}
/* Line 1529 of yacc.c.  */
#line 92 "tp3.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

