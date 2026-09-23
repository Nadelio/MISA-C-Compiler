#ifndef ASM_LABELS_H
#define ASM_LABELS_H

/*
 * Classify MISA labels as code or data so sema can check
 * extern declarations against the label type
 *
 * A label is data only if `emb` or `res` are on the same line (e.g. foo emb bar)
 */
typedef enum {
	ASM_LABEL_UNKNOWN = 0, /* not found */
	ASM_LABEL_CODE,
	ASM_LABEL_DATA
} AsmLabelKind;

typedef struct AsmLabelTable AsmLabelTable;

/*
 * scans the given .asm files and builds the label table,
 * local labels are stored as "global.local".
 * Unopenable paths are skipped
 */
AsmLabelTable *asm_labels_scan(char **paths, int count);

/* ASM_LABEL_UNKNOWN if the label isn't found */
AsmLabelKind   asm_labels_lookup(const AsmLabelTable *t, const char *name);

void           asm_labels_free(AsmLabelTable *t);

#endif /* ASM_LABELS_H */