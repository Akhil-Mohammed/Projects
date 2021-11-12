#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

typedef struct Item {
	char name[32];
	int weight;
	int value;
} Item;

Item parseLine(char* line) {
	Item it;
	memset(&it, 0, sizeof(Item));
	char* pch = strtok(line, " ");
	strncpy(it.name, pch, strlen(pch));
	pch = strtok(NULL, " ");
	it.weight = atoi(pch);
	pch = strtok(NULL, " ");
	it.value = atoi(pch);

	return it;
}

int readFile(char* str, Item** items_in) {
	FILE* fp;
	char* line = NULL;
	size_t len = 0;
	ssize_t read;
	fp = fopen(str, "r");
	if(!fp) {
		fprintf(stderr, "Unable to open file\n");
		exit(-1);
	}

	// Get the number of items from the first line
	read = getline(&line, &len, fp);
	int numLines = atoi(line);

	// Passed by reference from the caller, freed by caller
	*items_in = (Item *) malloc(numLines * sizeof(Item));
	Item* items = *items_in;
	int counter = 0;

	while((read = getline(&line, &len, fp)) != -1) {
		Item it = parseLine(line);
		memcpy(&items[counter++], &it, sizeof(Item));
	}

	fclose(fp);
	free(line);

	return numLines;
}

void knapsack(Item* items, int num_items, int total_weight) {
	/*
	For simplicity in this function I just i and j
	i == the current weight unit (row)
	j == the current item (column)
	*/

	int n = num_items;
	int w = total_weight;
	int* weights = (int*) malloc(n * sizeof(int));
	int* values = (int*) malloc(n * sizeof(int));
	int* mat = malloc(n * w * sizeof(int));

	/*
	3D matrix of bools
	items_in_bag[x][y] is an array of bools of length num_items
	If any position in this array is true,
	that item is in the solution for mat[x][y]
	*/
	bool** items_in_bag = (bool**) malloc(n * w * sizeof(bool*));
	bool* all_false = (bool*) malloc(n * sizeof(bool));

	int i, j = 0;
	for(j=0; j<n; j++) {
		all_false[j] = false;
		weights[j] = items[j].weight;
		values[j] = items[j].value;
	}
	for(i=0; i<w; i++) {
		for(j=0; j<n; j++) {
			mat[i * n + j] = 0;
			items_in_bag[i * n + j] = malloc(n * sizeof(bool));
			memcpy(items_in_bag[i * n + j], all_false, n * sizeof(bool));
		}
	}

	// First cell
	if(weights[0] <= 1) {
		mat[0] = values[0];
		items_in_bag[0][0] = true;
	}
	for(i=0; i<w; i++) {
		for(j=0; j<n; j++) {
			if(i == 0 && j == 0) continue;
			int cur_weight = weights[j];
			int cur_value = values[j];
			// at row 0 the weight capacity is 1
			int capacity = i+1;

			int max_value_without_cur = (j == 0) ? 0 : mat[i*n + (j-1)];
			int max_value_with_cur = 0;
			int remaining_capacity = 0;
			if(capacity >= cur_weight) {
				remaining_capacity = capacity - cur_weight;
				int max_under_remaining_capacity = 0;
				if(remaining_capacity >= 1) {
					max_under_remaining_capacity = (j == 0) ? 0 : mat[(remaining_capacity-1) * n + (j-1)];
				}
				max_value_with_cur = cur_value + max_under_remaining_capacity;
			}

			if(max_value_without_cur >= max_value_with_cur) {
				mat[i * n + j] = max_value_without_cur;
				if(j > 0)
					memcpy(items_in_bag[i * n + j], items_in_bag[i*n + (j-1)], n*sizeof(bool));
			} else {
				mat[i * n + j] = max_value_with_cur;
				if(j > 0 && remaining_capacity > 0) {
					memcpy(items_in_bag[i * n + j], items_in_bag[(remaining_capacity-1) * n + (j-1)], n*sizeof(bool));
				}
				bool* this_row = items_in_bag[i * n + j];
				this_row[j] = true;
			}
		}
	}

	bool* final_out = items_in_bag[n*w-1];
	int final_weight = 0;
	int final_value = 0;
	for(j=0; j<n; j++) {
		if(final_out[j]) {
			printf("%s\n", items[j].name);
			final_value += items[j].value;
			final_weight += items[j].weight;
		}
	}

	printf("%d / %d\n", final_value, final_weight);
	
	for(i=0; i<w; i++) {
		for(j=0; j<n; j++) {
			// printf("%d ", mat[i*n + j]);
			free(items_in_bag[i * n + j]);
		}
		// printf("\n");
	}

	free(mat);
	free(items_in_bag);
	free(all_false);
	free(weights);
	free(values);
}

int main(int argc, char* argv[]) {
	if(argc != 3) {
		fprintf(stderr, "Incorrect number of arguments. Usage: ./knapsack <weight> <file>\n");
		exit(-1);
	}
	int weight_limit = atoi(argv[1]);
	if(weight_limit < 1) {
		fprintf(stderr, "The weight must be a positive integer!\n");
		exit(-1);
	}
	char* manifest_filename = argv[2];
	Item* items;
	int num_items = readFile(manifest_filename, &items);
	knapsack(items, num_items, weight_limit);
	free(items);
	return 0;
}