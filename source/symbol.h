/*
 * .: Symbol table implementation.
 *
 * ?: Nikolaos S. Papaspyrou (nickie@softlab.ntua.gr)
 * @: Mon 03 Jun 2013 08:37:25 PM EEST
 *
 */

#ifndef __SYMBOL_H__
#define __SYMBOL_H__

/* ---------------------------------------------------------------------
   -------------------------- ����� bool -------------------------------
   --------------------------------------------------------------------- */

#include <stdbool.h>
#include <llvm-c/Core.h>
#include <llvm-c/Analysis.h>
/*
 *  �� �� �������� include ��� ������������� ��� ��� ���������
 *  ��� C ��� ��������������, �������������� �� �� �� ��������:
 */

#if 0
typedef enum { false=0, true=1 } bool;
#endif


/* ---------------------------------------------------------------------
   ------------ ������� �������� ��� ������ �������� -------------------
   --------------------------------------------------------------------- */

#define START_POSITIVE_OFFSET 8     /* ������ ������ offset ��� �.�.   */
#define START_NEGATIVE_OFFSET 0     /* ������ �������� offset ��� �.�. */

/* ---------------------------------------------------------------------
   --------------- ������� ����� ��� ������ �������� -------------------
   --------------------------------------------------------------------- */

/* ����� ��������� ��� ��� ��������� ��� �������� */

typedef int           RepInteger;         /* ��������                  */
typedef char          RepBoolean;         /* ������� �����             */
typedef char          RepChar;            /* ����������                */
typedef double        RepReal;            /* �����������               */
typedef const char *  RepString;          /* �������������             */

/* ����� ��������� ��� ������������� ����������� */

typedef struct Type_tag * Type;

struct Type_tag {
	enum {                               /***** �� ����� ��� ����� ****/
		TYPE_VOID,                        /* ����� ����� ������������� */
		TYPE_INTEGER,                     /* ��������                  */
		TYPE_BOOLEAN,                     /* ������� �����             */
		TYPE_CHAR,                        /* ����������                */
		TYPE_REAL,                        /* �����������               */
		TYPE_ARRAY,                       /* ������� ������� ��������  */
		TYPE_IARRAY,                      /* ������� �������� �������� */
	} kind;
	Type           refType;              /* ����� ��������            */
	RepInteger     size;                 /* �������, �� ����� ������� */
	unsigned int   refCount;             /* �������� ��������         */
};

/* ����� �������� ��� ������ �������� */

typedef enum {
	ENTRY_VARIABLE,                       /* ����������                 */
	ENTRY_CONSTANT,                       /* ��������                   */
	ENTRY_FUNCTION,                       /* �����������                */
	ENTRY_PARAMETER,                      /* ���������� �����������     */
	ENTRY_TEMPORARY                       /* ���������� ����������      */
} EntryType;

/* ����� ���������� ���������� */

typedef enum {
	PASS_BY_VALUE,                        /* ���' ����                  */
	PASS_BY_REFERENCE                     /* ���' �������               */
} PassMode;

/* ����� �������� ���� ������ �������� */

typedef struct SymbolEntry_tag SymbolEntry;

struct SymbolEntry_tag {
	const char   * id;                 /* ����� ��������������          */
	EntryType      entryType;          /* ����� ��� ��������            */
	unsigned int   nestingLevel;       /* ����� �����������             */
	unsigned int   hashValue;          /* ���� ���������������          */
	SymbolEntry  * nextHash;           /* ������� ������� ���� �.�.     */
	SymbolEntry  * nextInScope;        /* ������� ������� ���� �������� */
	LLVMValueRef   Valref;             /* The allocated space */

	union {                            /* ������� �� ��� ���� ��������: */

		struct {                                /******* ��������� *******/
			Type          type;                  /* �����                 */
			int           offset;                /* Offset ��� �.�.       */
		} eVariable;

		struct {                                /******** ������� ********/
			Type          type;                  /* �����                 */
			union {                              /* ����                  */
				RepInteger vInteger;              /*    �������            */
				RepBoolean vBoolean;              /*    ������             */
				RepChar    vChar;                 /*    ����������         */
				RepReal    vReal;                 /*    ����������         */
				RepString  vString;               /*    ������������       */
			} value;
		} eConstant;

		struct {                                /******* ��������� *******/
			bool          isForward;             /* ������ forward        */
			size_t        argno;                 // Number of arguments the function is accepting (hold the max value for vararg support?)
			SymbolEntry * firstArgument;         /* ����� ����������      */
			SymbolEntry * lastArgument;          /* ��������� ����������  */
			Type          resultType;            /* ����� �������������   */
			enum {                               /* ��������� ����������  */
				PARDEF_COMPLETE,                    /* ������ �������     */
				PARDEF_DEFINE,                      /* �� ���� �������    */
				PARDEF_CHECK                        /* �� ���� �������    */
			} pardef;
			int           firstQuad;             /* ������ �������        */
		} eFunction;

		struct {                                /****** ���������� *******/
			Type          type;                  /* �����                 */
			int           offset;                /* Offset ��� �.�.       */
			PassMode      mode;                  /* ������ ����������     */
			SymbolEntry * next;                  /* ������� ����������    */
		} eParameter;

		struct {                                /** ��������� ��������� **/
			Type          type;                  /* �����                 */
			int           offset;                /* Offset ��� �.�.       */
			int           number;
		} eTemporary;

	} u;                               /* ����� ��� union               */
};

/* ����� ������� �������� ��� ���������� ���� ���� �������� */

typedef struct Scope_tag Scope;

struct Scope_tag {
	unsigned int   nestingLevel;             /* ����� �����������      */
	unsigned int   negOffset;                /* ������ �������� offset */
	Scope        * parent;                   /* ������������ ��������  */
	SymbolEntry  * entries;                  /* ������� ��� ���������  */
};

/* ����� ���������� ���� ������ �������� */

typedef enum {
	LOOKUP_CURRENT_SCOPE,
	LOOKUP_ALL_SCOPES
} LookupType;

/* ---------------------------------------------------------------------
   ------------- ��������� ���������� ��� ������ �������� --------------
   --------------------------------------------------------------------- */

extern Scope        * currentScope;       /* �������� ��������         */
extern unsigned int   quadNext;           /* ������� �������� �������� */
extern unsigned int   tempNumber;         /* �������� ��� temporaries  */

extern const Type typeVoid;
extern const Type typeInteger;
extern const Type typeBoolean;
extern const Type typeChar;
extern const Type typeReal;

/* ---------------------------------------------------------------------
   ------ ��������� ��� ����������� ��������� ��� ������ �������� ------
   --------------------------------------------------------------------- */

void          initSymbolTable    (unsigned int size);
void          destroySymbolTable (void);

void          openScope          (void);
void          closeScope         (void);

SymbolEntry * newVariable        (const char * name, Type type);
SymbolEntry * newConstant        (const char * name, Type type, ...);
SymbolEntry * newFunction        (const char * name);
SymbolEntry * newParameter       (const char * name, Type type,
								  PassMode mode, SymbolEntry * f);
SymbolEntry * newTemporary       (Type type);

void          forwardFunction    (SymbolEntry * f);
void          endFunctionHeader  (SymbolEntry * f, Type type);
void          destroyEntry       (SymbolEntry * e);
SymbolEntry * lookupEntry        (const char * name, LookupType type,
								  bool err);

Type          typeArray          (RepInteger size, Type refType);
Type          typeIArray         (Type refType);
Type          typePointer        (Type refType);
void          destroyType        (Type type);
unsigned int  sizeOfType         (Type type);
bool          equalType          (Type type1, Type type2);
void          printType          (Type type);
void          printMode          (PassMode mode);

void printSymbolTable            (void);

#endif
