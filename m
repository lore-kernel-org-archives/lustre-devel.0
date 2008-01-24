From: Peter J Braam <Peter.Braam@Sun.COM>
Date: Thu, 24 Jan 2008 17:08:17 +0800
Subject: [Lustre-devel] flash cache page
In-Reply-To: <1201135464.14768.13.camel@linux.site>
References: <478E29FF.2050306@sun.com> <478E52AE.4060801@sun.com>
	<1200609618.30173.3.camel@linux.site> <47968E73.9020401@sun.com>
	<1201135464.14768.13.camel@linux.site>
Message-ID: <47985581.1070702@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>> 1 Use case table.
>>
>> i. we decided on an implementation constraint to store both file layouts 
>> as attributes of objects in a redirection layer in the client.  These 
>> layouts would be obtained from the MDS cluster, see (iv)
>>
>> ii. We decided that locks would be taken in a hierarchical  manner -  
>> the flash cache would run a LDLM and locks would be taken there.
>>
>> iii. Correctness would be handled automatically through the 
>> hierarchy.    
>>     
>
>
>   
>> However, to avoid a lot of reading "write only locks" used 
>> when entire pages are written are probably desirable (i.e. the caching 
>> infrastructure on the flash OST's is different from a Lustre client).
>>
>>     
>
>   
If a client writes a full page, the page should not first be read by the 
flash cache.  Almost too obvious perhaps.

- Peter -
