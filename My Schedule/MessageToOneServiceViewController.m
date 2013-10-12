//
//  MessageToOneServiceViewController.m
//  Mitt Schema
//
//  Created by Team SEA: Amelie Sjöstrand Gereholt, Ashraf Jibrael, Emma Boquist,
//  Jens Hagfeldt, Joanna Hemmingsson, Kristoffer Bergkvist. All rights reserved.
//

#import "MessageToOneServiceViewController.h"
#import "MasterViewController.h"
#import "Message.h"
#import "Message+Json.h"


@implementation MessageToOneServiceViewController

@synthesize allStudentNames, studentNamePicker, subjectTextfield, messageTextfield, receiverLabel, sendPrivateMessageButton, receiver, subject, writtenMessage, messageSender, type, title;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    // Setting default-receiver to the label on first row in UIPickerView
    NSString *receiverName = [NSString stringWithFormat:@"Receiver: %@", [allStudentNames objectAtIndex:0]];
    
    receiver = [allStudentNames objectAtIndex:0];
    receiverLabel.text = receiverName;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"hav2"]];
    
    self.title = [NSString stringWithFormat:@"New message to"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return allStudentNames.count;
}


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [allStudentNames objectAtIndex:row];
}


- (void)pickerView:(UIPickerView *)thePickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    receiver = [allStudentNames objectAtIndex:row];
    receiverLabel.text = [NSString stringWithFormat:@"Receiver: %@",[allStudentNames objectAtIndex:row]];
    NSLog(@"Receiver for message was set to student: %@.", receiver);
}


- (IBAction)sendPrivateMessageButton:(id)sender

{
    // We first check that a student has been chosen from the UIPickerView.
    // All of the textfields should also have been set with some data.
    
    
    if ([receiverLabel.text  isEqual: @""])
        
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert"
                                                       message:@"Please choose a receiver for your message"
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        
        [alert show];
        
        NSLog(@"Please choose a receiver for your message.");
        
    } else {
        
        if ([subjectTextField.text isEqual: @""]){
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert"
                                                           message:@"Please enter a subject for your message"
                                                          delegate:nil
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
            
            [alert show];
            
            NSLog(@"Please enter a subject for your message.");
            
        } else {
            
            if ([messageTextField.text isEqual: @""]){
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert"
                                                               message:@"Please type a message in the textfield"
                                                              delegate:nil
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
                
                [alert show];
                
                NSLog(@"Please type a message in the textfield.");
                
            } else {
                
                subject = subjectTextField.text;
                writtenMessage = messageTextField.text;
                title = @"title";
                messageSender = @"admin";
                type = @"message";
                
                NSLog(@"%@ wrote message: %@ to: %@ with the title: %@ and subject: %@.", messageSender, writtenMessage, receiver, subject, title);
                
                Message *myMessage = [[Message alloc] initWithTitle:title
                                                            subject:subject
                                                             sender:messageSender
                                                           receiver:receiver
                                                               type:type
                                                            message:writtenMessage];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                               message:@"Your message was sent"
                                                              delegate:nil
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
                
                [alert show];
                
                subjectTextField.text = @"";
                messageTextField.text = @"";
                
                // Re-setting the send-button
                [sendPrivateMessageButton setHighlighted:NO];
                
                [self saveWrittenMessage:myMessage];
                
            } // end else
            
        } // end else
        
    } // end if
    
}
-(void)saveWrittenMessage:(NSString*)message
{
        NSDictionary *messageAsJson = [self serializeMessageToJson:message];
        NSData *messageAsData = [NSJSONSerialization dataWithJSONObject:messageAsJson options:NSJSONWritingPrettyPrinted error:NULL];
        
        NSURL *url = [NSURL URLWithString:@"http://kakis.iriscouch.com/schedule_messages"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
        
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:messageAsData];
        
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:nil];
        [connection start];
        
        NSRunLoop *loop = [NSRunLoop currentRunLoop];
        [loop run];
}
- (IBAction)dissmissSubjectFieldKeyboard:(id)sender
{
    [sender resignFirstResponder];
    subject = subjectTextfield.text;
    NSLog(@"Subject was set to: %@", subject);
}
- (IBAction)dissmissMessageFieldKeybord:(id)sender
{
    [sender resignFirstResponder];
    writtenMessage = messageTextfield.text;
    NSLog(@"Message was set to: %@", writtenMessage);
}
#pragma mark - Serializing objects to json

-(id)serializeMessageToJson:(id) object
{
    NSObject *result = [[NSObject alloc] init];
    result = [object jsonValue];
    return result;
}
@end
