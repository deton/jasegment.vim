#!/usr/bin/awk -f
# convert KNB corpus1 (KNP output format)
# to TinySegmenterMaker input format (space separated segments) for Bunsetu
/^#/ {
	head = 1;
	next;
}
/^*/ {
	if (!head) {
		printf(" ");
	} else {
		head = 0;
	}
	next;
}
/^+/ {
	next;
}
/^EOS/ {
	printf("\n");
	head = 1;
	next;
}
{
	printf("%s", $1);
}
