#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Oct 16 10:21:35 2020

@author: jpaganini
"""
import sys
import os
import glob
import fastaparser
import re
from collections import defaultdict



#1. Create a dictionary with the lengths of each of the contigs included in the predictions

bin_length_dict={}

def create_bin_length_dict(strain):
    #move to the strain directory and list all bins for that strains/ # this will have to be modified 
    # for every tool
    #bin_length_dict={}
    global bin_length_dict
    global predictions_directory
    global total_bin_lengths
    bin_length_dict={}
    total_bin_lengths={}
    os.chdir(predictions_directory+strain)
    bins=glob.glob(binname+'*fasta') #this will have to change for every software
    for prediction in bins:
        prediction_modified=prediction.replace('.fasta','')
        print(prediction_modified)
        with open(prediction) as fasta_prediction:
            prediction_parser = fastaparser.Reader(fasta_prediction, parse_method='quick')
            for seq in prediction_parser:
                #the contig name might have to be change for every software
                contig_name=seq.header.replace('>','')
                contig_name=contig_name.split('_')[0:splitpoint]
                contig_name='_'.join(contig_name)
                contig_length=len(seq.sequence)
                bin_length_dict[contig_name]=contig_length
                if prediction_modified in total_bin_lengths:
                    total_bin_lengths[prediction_modified]+=int(contig_length)
                else:
                    total_bin_lengths[prediction_modified]=int(contig_length)
                            
    os.chdir(wd)

def bin_status(strain):
    global bin_length_dict
    global total_bin_lengths
    os.chdir(alignment_directory)
    try:
        os.chdir(strain)
        bins=glob.glob(binname+'*') #this might have to be changed for the different softwares
        #this loop will run for every bin in the strain (which is defined outside the function)
        for prediction in bins:
            correct_references=set()#this is a set for holding the references_id of the correct alignments
            correct_lengths={} #this is a dictionary {reference_id:length_of_contig}
            correct_contig_count={}
            correct_length_percentages={}
            correct_count_percentages={}
            ambiguous_references=set() #this is a set for holding the references names of the ambiguous alignments
            ambiguous_count=0
            unaligned_length=0 #new line
            unaligned_count=0 #new line
            #new_prediction=prediction.replace('.','-') #change format found on quast output
            low_qcov=0
            min_alignnment_pos_dict=defaultdict(list)
            max_alignnment_pos_dict=defaultdict(list)
            overlapping={}
            
            try:
                with open(prediction+'/contigs_reports/all_alignments_'+prediction+'.tsv') as contig_alignment:
                    all_lines=contig_alignment.readlines()[1:]
                    i=0
                    information_lines=[]
                    #This will loop thru every line in the output file from QUAST
                    for line in all_lines:
                        line=line.rstrip()
                        
                        if 'correct_unaligned' in line: #these are contigs that have a region aligned and another region unaligned.
                            information=information_lines[0].split('\t')
                            reference_name=information[4] #this is the replicon reference id
                            alignment_length=abs(int(information[3])-int(information[2]))+1 #LENGTH OF THE ALIGNMENT
                            indels=abs(alignment_length-(abs(int(information[0])-int(information[1]))+1))
                            alignment_length=alignment_length-indels #LENGTH OF THE ALIGNMENT
                            contig_name=information[5].split('_')[0:splitpoint]                                
                            contig_name='_'.join(contig_name)

                                
                            #Gather the information from this partially unaligned contig.
                            contig_length=information[5].split('_')[3]
                            #contig_coverage=information[5].split('_')[5]
                            with open('../../quast_statistics/'+mode+'/'+mode+'_unaligned_contigs.csv', 'a+') as unaligned_file:
                                unaligned_file.write(strain+','+contig_name+','+contig_length+','+'\n')

                                
               #If more than 90% of the contig length is aligned, we will consider this as a correct alignment 
                            if int(alignment_length) >= int(bin_length_dict[contig_name])*0.9:                        
                                correct_references.add(reference_name)
                                
                                #gather alignment ranges for later evaluation of overlapping positions
                                reference_positions=[int(information[0]),int(information[1])]
                                start=str(min(reference_positions))
                                end=str(max(reference_positions))
                                min_alignnment_pos_dict[reference_name].append(start)
                                max_alignnment_pos_dict[reference_name].append(end)
                                 
                                #register the name of the correct contig alignment
                                with open('../../quast_statistics/'+mode+'/'+mode+'_references_file.csv', 'a+') as reference_file:
                                    reference_file.write(strain+','+prediction+','+reference_name+','+contig_name+'\n')
                                
                                #add the length of the alignment to the correct_lengths dictionary    
                                if reference_name in correct_lengths:
                                    correct_lengths[reference_name]=int(correct_lengths[reference_name])+int(alignment_length)    
                                else:
                                    correct_lengths[reference_name]=int(alignment_length)
                                      

                                if reference_name in correct_contig_count:
                                    correct_contig_count[reference_name]=float(correct_contig_count[reference_name])+1    
                                else:
                                    correct_contig_count[reference_name]=1
                                    
                          #If less than 90% of the contig is aligned, we will consider this as unaligned contig            
                            else:
                                unaligned_length+=int(alignment_length)
                                unaligned_count+=1
                                low_qcov+=1
                              
                            i+=1
                            information_lines=[]
                    
                        
                        elif 'unaligned' in line:  #Consider unaligned regions
                                unaligned_length+=int(line.split('\t')[2])
                                unaligned_count+=1
                                information_lines=[]
                                i+=1
                                
                                #we will gather the information of the unaligned contig.
                                information=line.split('\t')
                                #contig_coverage=information[1].split('_')[5]
                                contig_length=line.split('\t')[2]
                                contig_name=information[1].split('_')[0:splitpoint]                                
                                contig_name='_'.join(contig_name)
                                with open('../../quast_statistics/'+mode+'/'+mode+'_unaligned_contigs.csv', 'a+') as unaligned_file:
                                    unaligned_file.write(strain+','+contig_name+','+contig_length+','+'\n')
                               #########################################################
                        
                                               
                        elif 'correct' in line:
                            #If we found any of this words around previous to the Correct match, it means that there was some minor problem with the Assembly of that contig, and that alignment is not perfect. See QUAST MANUAL.                              
                            if any('indel' in words for words in information_lines) or any('local misassembly' in words for words in information_lines) or any('scaffold gap' in words for words in information_lines) or any('linear representation of circular genome' in words for words in information_lines):
                                  #we will create a dictionary that will temporarly accumulate the alignment lengths of the different secitions of the contig.
                                  temporary_alignment_dict={}
                                  total_information_lines=len(information_lines)
                                  #we will create a dictionary that will contain the alignments ranges temporarly.
                                  temporary_min_alignnment_pos_dict=defaultdict(list)
                                  temporary_max_alignnment_pos_dict=defaultdict(list)
                                  
                                  j=0
                                  while j < total_information_lines:
                                          alignment_information=information_lines[j].split('\t')
                                          if any('False' in words for words in alignment_information): #skipping false alignments
                                              j+=1
                                              
                                          else:
                                              #if line contains information about the alignment do the next block of code. If it doesn't it will skip the line.
                                              try:
                                                   #this section of the code will gather the information on the refrence replicon andof the contig name.                                   
                                                  reference_name=alignment_information[4]
                                                  contig_name=alignment_information[5].split('_')[0:splitpoint]
                                                  contig_name='_'.join(contig_name)
                                                  alignment_length=abs(int(alignment_information[3])-int(alignment_information[2]))+1 #LENGTH OF THE ALIGNMENT
                                                  indels=abs(alignment_length-(abs(int(alignment_information[0])-int(alignment_information[1]))+1))
                                                  alignment_length=alignment_length-indels
                                                  
                                                  
                                                  #gather alignment ranges for later evaluation of overlapping positions
                                                  reference_positions=[int(alignment_information[0]),int(alignment_information[1])]
                                                  start=str(min(reference_positions))
                                                  end=str(max(reference_positions))
                                                  temporary_min_alignnment_pos_dict[reference_name].append(start)
                                                  temporary_max_alignnment_pos_dict[reference_name].append(end) 
                                                                                            

                                                  if reference_name in temporary_alignment_dict:
                                                      temporary_alignment_dict[reference_name]=int(temporary_alignment_dict[reference_name])+int(alignment_length) 
                                                  else:
                                                      temporary_alignment_dict[reference_name]=int(alignment_length)
            
                                                  #go to the next accumulated line
                                                  j+=1
                                                  
                                              except:
                                                  j+=1
                                
                                  #now we will check if the accumulated lengths of alignments correspond to 90% of the contig length        
                                  for reference_name in temporary_alignment_dict:
                                      if int(temporary_alignment_dict[reference_name]) >= int(bin_length_dict[contig_name])*0.9:
                                          #if this true, we will count the alignment as correct and we will add it to the correct_lenths dictionary.
                                          correct_references.add(reference_name)
                                          
                                          #now we will merge the dictionary of the alignment positions
                                          entry_numbers=len(temporary_min_alignnment_pos_dict[reference_name])
                                          k=0
                                          while k < entry_numbers:
                                              start=temporary_min_alignnment_pos_dict[reference_name][k]
                                              end=temporary_max_alignnment_pos_dict[reference_name][k]
                                              min_alignnment_pos_dict[reference_name].append(start)
                                              max_alignnment_pos_dict[reference_name].append(end)
                                              k+=1
                                                  
                                              
                                        
                                          if reference_name in correct_lengths:
                                              correct_lengths[reference_name]=int(correct_lengths[reference_name])+int(temporary_alignment_dict[reference_name]) 
                                          else:
                                              correct_lengths[reference_name]=int(temporary_alignment_dict[reference_name])
                                          
                                          if reference_name in correct_contig_count:
                                              correct_contig_count[reference_name]=float(correct_contig_count[reference_name])+1    
                                          else:
                                              correct_contig_count[reference_name]=1
                                                  
                                              #we will andd the name of the contig and the name of the refrence to the reference_file. This will be later used to study atb-R location
                                          with open('../../quast_statistics/'+mode+'/'+mode+'_references_file.csv', 'a+') as reference_file:
                                              reference_file.write(strain+','+prediction+','+reference_name+','+contig_name+'\n')
                                              
                                        #If less than 90% of the contig is aligned, we will consider this as unaligned contig      
                                      else:
                                          unaligned_length+=int(alignment_length)
                                          unaligned_count+=1
                                          low_qcov+=1
                                  
                                #after analyzing the data accumulated until we foound the 'correct' line,we will clean the saved data and then move to the next line.
                                  information_lines=[]
                                  i+=1
   
                          #it the alignment is 100% correct and quast found no problems with it.
                            else:
                                information=all_lines[i-1].split('\t')
                                reference_name=information[4] #this is the replicon reference id
                                alignment_length=abs(int(information[3])-int(information[2]))+1 #LENGTH OF THE ALIGNMENT
                                indels=abs(alignment_length-(abs(int(information[0])-int(information[1]))+1))
                                alignment_length=alignment_length-indels #LENGTH OF THE ALIGNMENT
                                contig_name=information[5].split('_')[0:splitpoint]
                                contig_name='_'.join(contig_name) #NAME OF THE CONTIG
                                
                                
               #Now we will check if the length of the correct alignment is more than 90% of the length of the contig.
               #If it is, we will count this as correct. 
                                if int(alignment_length) >= int(bin_length_dict[contig_name])*0.9:                        
                                    correct_references.add(reference_name)
                                    
                                    #gather alignment ranges for later evaluation of overlapping positions
                                    reference_positions=[int(information[0]),int(information[1])]
                                    start=str(min(reference_positions))
                                    end=str(max(reference_positions))
                                    min_alignnment_pos_dict[reference_name].append(start)
                                    max_alignnment_pos_dict[reference_name].append(end) 
      
                    #Add the length of the alignment to the dictionary correct_lengths. This will be use to calculate the purity percentage of the bin
                                    if reference_name in correct_lengths:
                                        correct_lengths[reference_name]=int(correct_lengths[reference_name])+int(alignment_length)    
                                    else:
                                        correct_lengths[reference_name]=int(alignment_length)
                                        
                  #Count the amount of correctly aligned contigs for each reference. This will be use to calculate the purity percentage of the bin
                                    if reference_name in correct_contig_count:
                                        correct_contig_count[reference_name]=float(correct_contig_count[reference_name])+1    
                                    else:
                                        correct_contig_count[reference_name]=1
                                        
                                    with open('../../quast_statistics/'+mode+'/'+mode+'_references_file.csv', 'a+') as reference_file:
                                        reference_file.write(strain+','+prediction+','+reference_name+','+contig_name+'\n')
                                    
                                    i+=1
                                    information_lines=[]
                                else: #If it is isn't,we will skip it.
                                    unaligned_length+=int(alignment_length)
                                    unaligned_count+=1
                                    low_qcov+=1
                                    i+=1
                                    information_lines=[]
                                    
                                    
                        #In the cases of contigs that ambiguosly aligned to multiple locations in the genome. We will consider this as correct alignments.
                        
                        elif 'ambiguous' in line: 
                            ambiguous_count+=1
                            for lines in information_lines:
                                #this section of the code will gather the information on the refrence replicon andof the contig name.
                                ambiguous_information=lines.split('\t')
                                ambiguous_reference_name=ambiguous_information[4]
                                ambiguous_references.add(ambiguous_reference_name)
                                ambiguous_alignment_length=abs(int(ambiguous_information[3])-int(ambiguous_information[2]))+1 #LENGTH OF THE ALIGNMENT
                                indels=abs(ambiguous_alignment_length-(abs(int(ambiguous_information[0])-int(ambiguous_information[1]))+1))
                                ambiguous_alignment_length=ambiguous_alignment_length-indels
                                contig_name=ambiguous_information[5].split('_')[0:splitpoint]
                                contig_name='_'.join(contig_name)
                                
                                 
                    
                                #Check if more than 90% of the contig correctly aligns
                                if int(ambiguous_alignment_length) >= int(bin_length_dict[contig_name])*0.9:
                                      correct_references.add(ambiguous_reference_name)
                                      
                                      #gather alignment ranges for later evaluation of overlapping positions
                                      reference_positions=[int(ambiguous_information[0]),int(ambiguous_information[1])]
                                      start=str(min(reference_positions))
                                      end=str(max(reference_positions))
                                      min_alignnment_pos_dict[ambiguous_reference_name].append(start)
                                      max_alignnment_pos_dict[ambiguous_reference_name].append(end)
                                      
                                      
                                      if ambiguous_reference_name in correct_lengths:                            
                                          correct_lengths[ambiguous_reference_name]=int(correct_lengths[ambiguous_reference_name])+int(ambiguous_alignment_length)
                                      else:
                                          correct_lengths[ambiguous_reference_name]=int(ambiguous_alignment_length)
                                          
                                    #Count the amount of correctly aligned contigs for each reference. This will be use to calculate the precision of the bin
                                      if ambiguous_reference_name in correct_contig_count:                                     
                                          correct_contig_count[ambiguous_reference_name]=float(correct_contig_count[ambiguous_reference_name])+1
                                      else:
                                          correct_contig_count[ambiguous_reference_name]=1
                                          
                                      with open('../../quast_statistics/'+mode+'/'+mode+'_references_file.csv', 'a+') as reference_file:
                                          reference_file.write(strain+','+prediction+','+ambiguous_reference_name+','+contig_name+'\n')
                                          
                                      with open('../../quast_statistics/'+mode+'/'+mode+'_ambiguous_references.csv', 'a+') as ambiguous_contigs_file:
                                          ambiguous_contigs_file.write(strain+','+prediction+','+ambiguous_reference_name+','+contig_name+','+str(ambiguous_alignment_length)+','+start+','+end+'\n')
                                          
                                else:
                                    unaligned_length+=int(alignment_length)
                                    unaligned_count+=1
                                    low_qcov+=1
                                    
                                
                                    
    
                            information_lines=[]
                            i+=1
                        
                        
                        
                        #In the cases of misassemblies
                        
                        elif 'misassembled' in line:
                            
                        #if we found a translocation information, we will split the alignment into the different replicons that it aligns to.
                        
                            if any('translocation' in words for words in information_lines):
                                total_information_lines=len(information_lines)
                                j=0
                                
                                #since there are probably multiple alignment lines in this cases, we will loop over the lines that were accumulated in the variable information_lines.
                                while j < total_information_lines:
                                    alignment_information=information_lines[j].split('\t')
                                    
                                    #We will skip alignments classified as false.
                                    
                                    if any('False' in words for words in alignment_information): 
                                        j+=1
                                        
                                    else:
                                        #we will try to gather alignment information. But some lines will not contain this information, therefore we will skip them.
                                        try:
                                            #this section of the code will gather the information on the refrence replicon andof the contig name.
                                            reference_name=alignment_information[4]
                                            contig_name=alignment_information[5].split('_')[0:splitpoint]
                                            contig_name='_'.join(contig_name)
                                            alignment_length=abs(int(alignment_information[3])-int(alignment_information[2]))+1 #LENGTH OF THE ALIGNMENT
                                            indels=abs(alignment_length-(abs(int(alignment_information[0])-int(alignment_information[1]))+1))
                                            alignment_length=alignment_length-indels
                                            contig_fraction=round(int(alignment_length)/int(bin_length_dict[contig_name]),2)
                                            
                                            
                                            #gather alignment ranges for later evaluation of overlapping positions
                                            reference_positions=[int(alignment_information[0]),int(alignment_information[1])]
                                            start=str(min(reference_positions))
                                            end=str(max(reference_positions))
                                            min_alignnment_pos_dict[reference_name].append(start)
                                            max_alignnment_pos_dict[reference_name].append(end) 
                                            
                                            #get the contig alignment positions for later fix of atb-r assignment problem  --NEW LINES                                           
                                            reference_positions_contigs=[int(alignment_information[2]),int(alignment_information[3])]
                                            start_contig=str(min(reference_positions_contigs))
                                            end_contig=str(max(reference_positions_contigs))
                                            
                                            
                                            #In this cases we will not have the limitation of evaluating 90% coverage of the contig, since by definition this is a hybrid contig.                                                                                              
                                            if reference_name in correct_lengths:
                                                correct_lengths[reference_name]=int(correct_lengths[reference_name])+int(alignment_length)    
                                            else:
                                                correct_lengths[reference_name]=int(alignment_length)
                                            
                                            if reference_name in correct_contig_count:
                                                correct_contig_count[reference_name]=float(correct_contig_count[reference_name])+float(contig_fraction)    
                                            else:
                                                correct_contig_count[reference_name]=float(contig_fraction)  
                                            
                                            j+=1
                                            
                                            with open('../../quast_statistics/'+mode+'/'+mode+'_references_file.csv', 'a+') as reference_file:
                                                      reference_file.write(strain+','+prediction+','+reference_name+','+contig_name+','+start_contig+','+end_contig+'\n') #new_line
                                                      
                                        #skipping lines that do not contain alignemtn information              
                                        except:
                                            j+=1
                                        
                                information_lines=[]
                                i+=1
                                
                            #in any other missasembly case, relocation or inversion, we will analyze the data as beofre, using the 90% filter for correct alignments 
                            else:
                                
                                #we will create a dictionary that will contain the total alignment lengths to different regions of the replicon.
                                temporary_alignment_dict={}
                                #we will create a dictionary that will contain the alignments ranges temporarly.
                                temporary_min_alignnment_pos_dict=defaultdict(list)
                                temporary_max_alignnment_pos_dict=defaultdict(list)
                                
                                total_information_lines=len(information_lines)
                                j=0
                                
                                #since there are probably multiple alignment lines in this cases, we will loop over the lines that were accumulated in the variable information_lines.
                                while j < total_information_lines:
                                    alignment_information=information_lines[j].split('\t')
                                    
                                    #skipping false alignments
                                    if any('False' in words for words in alignment_information):
                                        j+=1
                                        
                                    else:
                                        #we will try to gather alignment information. But some lines will not contain this information, therefore we will skip them.
                                        try:  
                                            #this section of the code will gather the information on the refrence replicon andof the contig name.                                                                                  
                                            reference_name=alignment_information[4]
                                            contig_name=alignment_information[5].split('_')[0:splitpoint]
                                            contig_name='_'.join(contig_name)
                                            alignment_length=abs(int(alignment_information[3])-int(alignment_information[2]))+1 #LENGTH OF THE ALIGNMENT
                                            indels=abs(alignment_length-(abs(int(alignment_information[0])-int(alignment_information[1]))+1))
                                            alignment_length=alignment_length-indels
                                            contig_fraction=round(int(alignment_length)/int(bin_length_dict[contig_name]),2)
                                            
                                            #gather alignment ranges for later evaluation of overlapping positions
                                            reference_positions=[int(alignment_information[0]),int(alignment_information[1])]
                                            start=str(min(reference_positions))
                                            end=str(max(reference_positions))
                                            temporary_min_alignnment_pos_dict[reference_name].append(start)
                                            temporary_max_alignnment_pos_dict[reference_name].append(end)
                                            
                                            #we will add the lenght of alignment to the temporary alignment lengths.
                                            if reference_name in temporary_alignment_dict:
                                                temporary_alignment_dict[reference_name]=int(temporary_alignment_dict[reference_name])+int(alignment_length)
        
                                            else:
                                                temporary_alignment_dict[reference_name]=int(alignment_length)
                                                
                                            j+=1

                                        except:

                                            j+=1
                                            
                                            
                                #now we will check if the accumulated alignment lenghts are over 90% of the contig length.          
                                for reference_name in temporary_alignment_dict:
                                    
                                    if int(temporary_alignment_dict[reference_name]) >= int(bin_length_dict[contig_name])*0.9:
                                        correct_references.add(reference_name)
                                        
                                        #Since the alignemtns are correct (more than 90%) we will add the temp_aligment_ranges.
                                        entry_numbers=len(temporary_min_alignnment_pos_dict[reference_name])

                                        k=0
                                        while k < entry_numbers:
                                            start=temporary_min_alignnment_pos_dict[reference_name][k]
                                            end=temporary_max_alignnment_pos_dict[reference_name][k]
                                            min_alignnment_pos_dict[reference_name].append(start)
                                            max_alignnment_pos_dict[reference_name].append(end)
                                            k+=1


                  
                        #Add the length of the alignment to the dictionary correct_lengths. This will be use to calculate the purity percentage of the bin
                                        if reference_name in correct_lengths:
                                            correct_lengths[reference_name]=int(correct_lengths[reference_name])+int(temporary_alignment_dict[reference_name]) 
                                        else:
                                            correct_lengths[reference_name]=int(temporary_alignment_dict[reference_name])
                                              
                                        if reference_name in correct_contig_count:
                                            correct_contig_count[reference_name]=float(correct_contig_count[reference_name])+1    
                                        else:
                                            correct_contig_count[reference_name]=1                                      
                                                                      
                                        with open('../../quast_statistics/'+mode+'/'+mode+'_references_file.csv', 'a+') as reference_file:
                                            reference_file.write(strain+','+prediction+','+reference_name+','+contig_name+'\n')
                                        
                                    else: #If it is isn't,we will skip it.
                                        unaligned_length+=int(alignment_length)
                                        unaligned_count+=1
                                        low_qcov+=1
    
                                        
                                i+=1
                                information_lines=[]
                                  
                                             
                        
                       #if no correct, or misassembled or ambiguous word is found, then we will save the line in the variable information_lines. 
                        else:
                            information_lines.append(line)
                            i+=1
                    
                            
                    #--------------------------------------------------------------------------------------------------------#
                    
                    #after gathering all the alignment informaiton we will analyze the overlappings in the alignments
                    for reference_name in min_alignnment_pos_dict:
                        number_of_alignments=len(min_alignnment_pos_dict[reference_name])
                        
                        k=1
                        while k<number_of_alignments:
                            l=0
                            while l<k:
                                if int(min_alignnment_pos_dict[reference_name][l])>=int(min_alignnment_pos_dict[reference_name][k]) and int(min_alignnment_pos_dict[reference_name][l])<=int(max_alignnment_pos_dict[reference_name][k]):
                                    if int(max_alignnment_pos_dict[reference_name][l]) >=int(max_alignnment_pos_dict[reference_name][k]):
                                        
                                        overlap_length= int(max_alignnment_pos_dict[reference_name][k])-int(min_alignnment_pos_dict[reference_name][l])+1
                                        if reference_name in overlapping:
                                            overlapping[reference_name]+=overlap_length
                                        else:
                                            overlapping[reference_name]=overlap_length
                                        
                                    else:
                                        overlap_length= int(max_alignnment_pos_dict[reference_name][l])-int(min_alignnment_pos_dict[reference_name][l])+1
                                        if reference_name in overlapping:
                                            overlapping[reference_name]+=overlap_length
                                        else:
                                            overlapping[reference_name]=overlap_length
                                            
                                    l+=1
                                
                                elif int(max_alignnment_pos_dict[reference_name][l])>int(min_alignnment_pos_dict[reference_name][k]) and int(max_alignnment_pos_dict[reference_name][l])<=int(max_alignnment_pos_dict[reference_name][k]):  

                                    if int(min_alignnment_pos_dict[reference_name][l]) >=int(min_alignnment_pos_dict[reference_name][k]):
                                        overlap_length= int(max_alignnment_pos_dict[reference_name][l])-int(min_alignnment_pos_dict[reference_name][l])+1
                                        if reference_name in overlapping:
                                            overlapping[reference_name]+=overlap_length
                                        else:
                                            overlapping[reference_name]=overlap_length
                                            
                                    else:
                                        overlap_length= int(max_alignnment_pos_dict[reference_name][l])-int(min_alignnment_pos_dict[reference_name][k])+1
                                        if reference_name in overlapping:
                                            overlapping[reference_name]+=overlap_length
                                        else:
                                            overlapping[reference_name]=overlap_length
                                            
                                    l+=1
                                 
                                else:

                                    l+=1
                                     
                            k+=1
                            
                      ##-----------------------------------------------------------------------------------
                      
                      #Now we will save the results obtained
                      
                    
                    
                    with open('../../quast_statistics/'+mode+'/'+mode+'_ambiguous_count.csv', 'a+') as ambiguous_count_file:
                        ambiguous_count_file.write(strain+','+prediction+','+str(ambiguous_count)+'\n')
                        
                    with open('../../quast_statistics/'+mode+'/low_coverage_contigs_'+mode+'.csv', 'a+') as low_coverage_file:
                        low_coverage_file.write(strain+','+str(low_qcov)+'\n')
                        
                        
                    for reference_name in overlapping:
                        with open('../../quast_statistics/'+mode+'/'+mode+'_overlapping.csv', 'a+') as overlapping_file:
                            overlapping_file.write(strain+','+prediction+','+reference_name+','+str(overlapping[reference_name])+'\n')
                        
                    
                    
                    #If there are correct alignmetns, calculate percentages and write statistics into a file.     
                    if len(correct_lengths)>0:
                    #Fill the percentages dictionary
                        for reference_name in correct_lengths:
                            if reference_name in overlapping:
                                correct_length_percentages[reference_name]=(int(correct_lengths[reference_name])-int(overlapping[reference_name]))/(int(total_bin_lengths[prediction]))
                            #new line
                                correct_count_percentages[reference_name]=float(correct_contig_count[reference_name])/(sum(correct_contig_count.values())+unaligned_count)
                                #print(strain, prediction,reference_name,str(int(correct_lengths[reference_name])-int(overlapping[reference_name])),correct_contig_count[reference_name],correct_length_percentages[reference_name],correct_count_percentages[reference_name])
                                with open('../../quast_statistics/'+mode+'/'+mode+'_alignments_statistics.csv', 'a+') as statistics_file:
                                    statistics_file.write(strain+','+prediction+','+reference_name+','+str(int(correct_lengths[reference_name])-int(overlapping[reference_name]))+','+str((total_bin_lengths[prediction]))+'\n')                            
                            else:
                                correct_length_percentages[reference_name]=int(correct_lengths[reference_name])/(total_bin_lengths[prediction])
                            #new line
                                correct_count_percentages[reference_name]=float(correct_contig_count[reference_name])/(sum(correct_contig_count.values())+unaligned_count)
                                #print(strain, prediction,reference_name,correct_lengths[reference_name],correct_contig_count[reference_name],correct_length_percentages[reference_name],correct_count_percentages[reference_name])
                                with open('../../quast_statistics/'+mode+'/'+mode+'_alignments_statistics.csv', 'a+') as statistics_file:
                                     statistics_file.write(strain+','+prediction+','+reference_name+','+str(correct_lengths[reference_name])+','+str((total_bin_lengths[prediction]))+'\n')                                  
                                 
                    
                    else:
                        print(strain,prediction,'no correct alignments')
                        with open('../../quast_statistics/'+mode+'/'+mode+'_alignments_statistics.csv', 'a+') as statistics_file:
                            statistics_file.write(strain+','+prediction+','+'no_correct_alignments'+','+'0'+','+'0'+'\n')                            
                                
                    
                   
            except FileNotFoundError:
                print('no_alignment_file')
                with open('../../quast_statistics/'+mode+'/'+mode+'_alignments_statistics.csv', 'a+') as statistics_file:
                         statistics_file.write(strain+','+prediction+','+'contig_length_below_1k'+','+'0'+','+'0'+'\n')    
                         
    except FileNotFoundError:
        os.chdir(wd)
        
                        
    os.chdir(wd)
                    
            
#set mode and dataset
dataset=str(sys.argv[1])
mode=str(sys.argv[2])        

if "mob_bac" in mode:
	splitpoint = 3
	binname = "plasmid"

elif "mob_uni" in mode:
	splitpoint = 1
	binname = "plasmid"

elif mode == "spades":
	splitpoint = 2
	binname = "*"
                
#directories paths
wd=os.path.dirname(os.path.realpath(__file__))
predictions_directory='../results/'+dataset+'/predictions_'+mode+'/'
alignment_directory='../results/'+dataset+'/quast_'+mode+'/'

os.chdir(predictions_directory) #this will have to change for every software
genomes=glob.glob('*') #this will have to change for every software
os.chdir(wd)

#make quast statistics directory for the specific mode
os.makedirs("../results/"+dataset+"/quast_statistics/"+mode,exist_ok=True)

for files in genomes:
	print(files)
	try:
		create_bin_length_dict(files)
	except:
		print("Error in create_bin_length_dict")
	try:
		bin_status(files)
	except:
		print('Error in bin_status')
