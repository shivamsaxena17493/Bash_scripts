#!/bin/bash

# collecting books of William Shakespeare from Gutenberg hosted data source
wget -c http://www.gutenberg.org/files/1524/1524-0.txt -O ws_book_1.txt
wget -c http://www.gutenberg.org/files/1112/1112.txt -O ws_book_2.txt
wget -c http://www.gutenberg.org/files/2267/2267.txt -O ws_book_3.txt
wget -c http://www.gutenberg.org/files/2253/2253.txt -O ws_book_4.txt
wget -c http://www.gutenberg.org/files/1513/1513-0.txt -O ws_book_5.txt
wget -c http://www.gutenberg.org/files/1120/1120.txt -O ws_book_6.txt

# punctuation will be removed from all books.
# punct_removed.txt new file will contain text cleaned.
# to normalize the words so its token frequency count will be dense.
# case normalized text data will be converted to word list.
cat ws_book* | tr -d '[:punct:]'| tr '[:upper:]' '[:lower:]' | tr -s '[[:space:]]' '\n' >  punct_rmv_case_norm_wrdlist.txt

if [ -e punct_rmv_case_norm_wrdlist.txt ]
then
    echo "Punctuation Removed Normalized Word List Found"

    # on word list, each word count will get determined and sorted on count.
	# from that top 20 most frequent words will be extracted. 
    cat punct_rmv_case_norm_wrdlist.txt | sort | uniq -c | sort -nr | head -20 > top_20_most_frq_words_punct_rm.txt
    
    echo "Top 20 Most Frequent Words Successfully Extracted To -- top_20_most_frq_words_punct_rm.txt"
else
    echo "Error: File Not Found - Word list file is not generated in current directory"
fi

if [ -e smart_stop_words.txt ]
then
    echo "Stop Words List Found"

    # using stop word list by SMART contains 571 stop words.
	# from the punct removed word list stop words will be removed.
    fgrep -v -w -f smart_stop_words.txt punct_rmv_case_norm_wrdlist.txt > stopwords_removed_word_list.txt
    
    echo "Stop Words Removed Successfully"
else
    echo "Error: File Not Found - Please copy stop word list file in current directory"
fi

if [ -e stopwords_removed_word_list.txt ]
then
    echo "Stop Word Removed Word list Found"

    # stop words will be removed from case normalized word list text file 
    cat stopwords_removed_word_list.txt | sort | uniq -c | sort -nr | head -20 > top_20_most_frq_words_stpw_rm.txt

    echo "Top 20 Most Frequent Words Successfully Extracted to -- top_20_most_frq_words_stpw_rm.txt"
else
    echo "Error: File Not Found - Word list file is not generated in current directory"
fi

# data cleanup, removing intermediary files generated to reach output
rm punct_rmv_case_norm_wrdlist.txt
rm stopwords_removed_word_list.txt

echo "Text preprocessing script ran successfully"