import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# SMTP Server Details
host = "mail.ofomusworldcare.co.uk"
port = 465  # SSL port
email = "mitm@ofomusworldcare.co.uk"
password = "qR{5y~%x#=A,"

# Email Details
sender_email = email
receiver_email = "preshitech111@gmail.com"
subject = "MITM Detection Report"

# Read contents from Results.txt and replace newlines with <br>
with open("Results.txt", "r") as file:
    file_contents = file.read()
    html_content = file_contents.replace("\n", "<br>")

# Create MIMEText object for HTML content
message = MIMEMultipart("alternative")
message["Subject"] = subject
message["From"] = sender_email
message["To"] = receiver_email

# Attach HTML content
html_part = MIMEText(html_content, "html")
message.attach(html_part)

# Send Email via SMTP
try:
    with smtplib.SMTP_SSL(host, port) as server:
        server.login(email, password)
        server.sendmail(sender_email, receiver_email, message.as_string())
    print("Email sent successfully!")
except Exception as e:
    print(f"Failed to send email. Error: {e}")
