struct Incomplete;

struct Empty {
};

struct Duplicate {
	int value;
	int value;
};

struct BadMembers {
	void nothing;
	int function(void);
	struct Incomplete incomplete;
};

struct NotLast {
	int values[];
	int tail;
};

union FlexibleUnion {
	int values[];
};

struct OnlyFlexible {
	int values[];
};

struct FlexibleTail {
	int count;
	int values[];
};

struct ContainsFlexible {
	struct FlexibleTail tail;
};

int main(void)
{
	return 0;
}