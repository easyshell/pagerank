#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <algorithm>
#include <vector>
#include <iomanip>
#include <queue>
#include <cstdlib>

using namespace std;


struct weibo_rank {
	weibo_rank(string id_, double rank_) {
		id = id_; rank = rank_;
	}
	bool operator < (const weibo_rank& wr) const {
		return rank < wr.rank;
	}
	string id;
	double rank;
};

class pri_weibo_rank: public weibo_rank {
	int from_file_idx;
	public:
		pri_weibo_rank(string id_, double rank_, int from_file_idx_) : weibo_rank(id_, rank_), from_file_idx(from_file_idx_) {}
		int get_from_file_idx() {
			return from_file_idx;
		}
};

class merge_sort {
	private:
		typedef priority_queue<pri_weibo_rank> pqpwr;
		pqpwr* contain_max;
		ifstream* part_file_read;
		ofstream out;
		char* outfile;
		int part_file_num;
	private:
		int set_read_file_stream() {
			part_file_read = new ifstream[1+part_file_num];
			for (int i = 0; i < part_file_num; i++) {
				char* fname = new char[512];
				sprintf(fname, "%d", i);
				part_file_read[i].open(fname, ios::in);
				delete fname;
			}
			return 0;
		}

		int set_write_file_stream() {
			out.open(outfile, ios::app);	
			return 0;
		}


		bool read_one_line(int idx, char* line) {
			if (! part_file_read[idx].is_open()) {
				cout << "error opening file" << endl; exit(1);
			}
			if (part_file_read[idx].eof()) return false;
			return part_file_read[idx].getline(line, 512);
		}

		pri_weibo_rank get_one_weibo_rank_from_file(int idx) {
			char* line = new char[512];
			if (read_one_line(idx, line)) {
				char id[512]; double rank = 0; char rank_tag[512];
				sscanf(line, "%s %lf %s", id, &rank, rank_tag);
				delete line;
				return pri_weibo_rank(id, rank, idx);
			}
			delete line;
			string id = "read fail";
			return pri_weibo_rank(id, -1, -1);
		}

		int init_contain_max() {
			int part_able_read_num = 0;
			contain_max = new pqpwr();
			while (!contain_max->empty()) contain_max->pop();
			for (int i = 0; i < part_file_num; i++) {
				pri_weibo_rank pwr = get_one_weibo_rank_from_file(i);
				if (pwr.get_from_file_idx() != -1) {
					contain_max->push(pwr);
					++part_able_read_num;
				} else {
					printf("part_read file %d is not exist or has nothing\n", i);
				}
			}
			printf("has able read_part file: %d\n", part_able_read_num);
			return 0;
		}

		int write_one_line_to_out(pri_weibo_rank& pwr) {
			if (! out.is_open()) {
				printf("outfile is not open\n");
				exit(1);
			}
			out << setprecision(17) << pwr.id << "\t" << pwr.rank << endl;
			return 0;
		}
		
		int merge_sort_core() {
			while(! contain_max->empty()) {
				pri_weibo_rank top = contain_max->top();
				write_one_line_to_out(top);
				int file_idx_of_top = top.get_from_file_idx();
				pri_weibo_rank pwr = get_one_weibo_rank_from_file(file_idx_of_top);
				if (pwr.get_from_file_idx() != -1) {
					contain_max->push(pwr);
				} else {
					part_file_read[file_idx_of_top].close();
					printf("file %d is read finished\n", file_idx_of_top);
				}
				contain_max->pop();
			}
			return 0;
		}

	public:
		merge_sort(char* outfile_, int part_file_num_) : outfile(outfile_), part_file_num(part_file_num_) {
			set_read_file_stream();
			set_write_file_stream();
			init_contain_max();
		}

		~merge_sort() {
			delete contain_max;
			delete[] part_file_read;
		}

		int work() {
			merge_sort_core();
			return 0;
		}
};

int main(int argc, char* argv[]) {
	char* outfile = new char[512];
	char* part_file_num_str = new char[512];
	strcpy(outfile, argv[1]);
	strcpy(part_file_num_str, argv[2]);
	int part_file_num = 0;
	sscanf(part_file_num_str, "%d", &part_file_num);
	merge_sort ms(outfile, part_file_num);
	ms.work();
	delete outfile;
	delete part_file_num_str;
	return 0;
}
