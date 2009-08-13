From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Thu, 13 Aug 2009 15:16:48 -0400
Subject: [Lustre-devel] Role of the Metadata Server during File I/O
In-Reply-To: <20090813184324.4BE6920DBF8C@hailoo.com>
References: <20090810223137.E018520DBF8C@hailoo.com>
	<034001ca1a93$cd8ec140$68ac43c0$@com>
	<20090811172405.5AA7420DBF8C@hailoo.com>
	<A1589B4A-DAE8-4022-A352-8D3709C163D5@sun.com>
	<20090813184324.4BE6920DBF8C@hailoo.com>
Message-ID: <357B2097-EF19-4E5E-9A98-F1358A91D1D7@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Aug 13, 2009, at 2:43 PM, office at hailoo.com wrote:
>>> Thanks for the information.  Doesn't this entail that for every  
>>> call  to write() involving a striped file, Lustre must necessarily  
>>> consult  all OSSs, in order to determine 1) the file size and 2)  
>>> if the  current write operation will extend the file?
>> Why does write need to know the entire file size? We only care if  
>> we  are extending currently accessed stripe. We know this the  
>> moment we  obtained the lock on
>> the stripe region we are interested in.
>>
> Consider the following situation:
> You have 4 OSTs and you create a file striped across all 4 OSTs, and  
> you set the stripe size to 4 bytes.  (Obviously that is too small,  
> but I just want to keep this simple.)
> The file is created and it starts out as a 0 byte file.  Now,  
> suppose you write one byte to offset 5.  So now Lustre has to write  
> one byte to the second OST.  But, in POSIX compliant file I/O, if  
> you write to an offset that is greater than the file size, the file  
> system must write zeros to the disk to fill the gap between the old  
> end of the file
>

This is a misconception. Nowhere does it says we must write zeroes to  
disk. We are fine as long as subsequent reads would get zeroes.
> and the offset.  So, in the case of Lustre, the system must not only  
> write a single byte to the second OST, it also must write 4 zero- 
> bytes to the first OST.  But in order to even know that is has to do  
> this, wouldn't Lustre need to know the entire file size?
>

No.
What happens is we write the data and necessary zeroes to 2nd OST (to  
fill the page where this one byte fits) and size on 1st ost remains 0,
lustre is smart enough to fill the next read with zeroes when it  
encounters access to that part of the file.
The file size on the other hand would be properly composed because we  
look at file size at every OST.

Bye,
     Oleg
