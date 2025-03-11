#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <thrust/sort.h>
#include <thrust/copy.h>
#include <iostream>
#include <fstream>
#include <chrono>

#define TYP int

int main()
{
	const int bufSize{ 50'000'000 };

	std::ifstream fileInputStream;
	fileInputStream.open("1.bin", std::ios::in | std::ios::binary);

	if (!fileInputStream.is_open())
		return -1;

	TYP* pBuffer;

	try {
		pBuffer = new TYP[bufSize];
	}
	catch (...) {
		return -2;
	}
	fileInputStream.seekg(9'000'000, std::ios::beg); //avoiding zero-area of file
	fileInputStream.read((char*)pBuffer, bufSize * sizeof(TYP));
	fileInputStream.close();

	if (fileInputStream.bad())
		return -4;

	thrust::host_vector<TYP> h_vec(pBuffer, pBuffer + bufSize);

	delete[] pBuffer;

	auto t1 = std::chrono::high_resolution_clock::now();
	thrust::device_vector<int> d_vec = h_vec;

	auto t2 = std::chrono::high_resolution_clock::now();
	thrust::sort(d_vec.begin(), d_vec.end()); //The main Operation

	auto t3 = std::chrono::high_resolution_clock::now();
	thrust::copy(d_vec.begin(), d_vec.end(), h_vec.begin());

	auto t4 = std::chrono::high_resolution_clock::now();
	
	const std::chrono::duration<double, std::milli> passed1 = t2 - t1;
	const std::chrono::duration<double, std::milli> passed2 = t3 - t2;
	const std::chrono::duration<double, std::milli> passed3 = t4 - t3;
	
	size_t tcopy{ (size_t)passed1.count() + (size_t)passed3.count() };
	size_t tsort{ (size_t)passed2.count() };
		
		
	std::cout << "Size of Vector = " << h_vec.size() << ", Time elapsed = ";
	std::cout  << tsort << " ms + " << tcopy << " ms" << std::endl;
}
