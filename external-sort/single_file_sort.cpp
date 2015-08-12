#include <iostream>
#include <fstream>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <algorithm>
#include <vector>
#include <iomanip>

using namespace std;

struct weibo_rank {
	weibo_rank(string id_, double rank_) {
		id = id_; rank = rank_;
	}
	bool operator < (const weibo_rank& wr) const {
		return rank > wr.rank;
	}
	string id;
	double rank;
};

int main(int argc, char* argv[]) {
	char filename[512];
	char outfile[512];
	strcpy(filename, argv[1]);
	strcpy(outfile, argv[2]);
	//printf("%s\n%s\n", filename, outfile);
	if (access(outfile, F_OK) != -1) {
		remove(outfile);
	}
	char buf[512];
	ifstream in(filename, ios::in);
	if (! in.is_open()) {
		cout << "error opening file" << endl; exit(1);
	}
	char id[512];
	double rank = 0;
	char nouse[512];
	vector<weibo_rank> file_content;
	file_content.clear();
	while (!in.eof()) {
		in.getline(buf, 512);
		sscanf(buf, "%s %lf %s", id, &rank, nouse);
		file_content.push_back(weibo_rank(id, rank));
	}
	sort(file_content.begin(), file_content.end());
	ofstream out;
	out.open(outfile, ios::app);

	for (int i = 0; i < (int)file_content.size(); i++) {
		if (out.is_open()) {
			out << setprecision(17) << file_content[i].id << "\t" << file_content[i].rank << endl;
		}
	}
	out.close();
	return 0;
}
