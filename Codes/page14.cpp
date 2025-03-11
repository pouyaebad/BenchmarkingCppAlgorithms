#include <vector>
#include <iostream>
#include <algorithm>
#include <fstream>
#include <chrono>
#include <execution>

#define TYP int

int main()
{
	const int bufSize{ 50'000'000 };

	std::ifstream fileInputStream;
	fileInputStream.open("1.bin", std::ios::in | std::ios::binary);

	if (!fileInputStream.is_open())
		return -1;
	
	TYP* pBuffer;

	try{
		pBuffer = new TYP[bufSize];
	}
	catch (...){
		return -2;
	}

	fileInputStream.seekg(9'000'000, std::ios::beg); //avoiding zero-area of file
	fileInputStream.read((char *)pBuffer, bufSize * sizeof(TYP));
	fileInputStream.close();

	if (fileInputStream.bad())
		return -4;

	std::vector<TYP> v(pBuffer, pBuffer + bufSize);

	delete [] pBuffer;


	auto tStart = std::chrono::high_resolution_clock::now(); 
	std::sort(std::execution::par, v.begin(), v.end()); //The main Operation
	auto tEnd = std::chrono::high_resolution_clock::now();


	const std::chrono::duration<double, std::milli> passed = tEnd - tStart;
	size_t timeElapsedProcessingTotal_ms{ (size_t)passed.count() };

	std::cout << "data type size = " << sizeof(TYP) << std::endl;
	std::cout << "Size of Vector = " << v.size() << ", Time elapsed = ";
	std::cout  << timeElapsedProcessingTotal_ms << " ms" << std::endl;
}
