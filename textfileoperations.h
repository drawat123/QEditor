#ifndef TEXTFILEOPERATIONS_H
#define TEXTFILEOPERATIONS_H

#include <QFile>
#include <QFontMetrics>
#include <QObject>
#include <QQuickTextDocument>
#include <QString>
#include <QTextCursor>
#include <QTextStream>
#include <QUrl>
#include <QtMath>

class TextFileOperations : public QObject
{
    Q_OBJECT
public:
    explicit TextFileOperations(QObject *parent = nullptr);

signals:

public slots:
    QString readFile(const QUrl &filePath);
    void saveFile(const QUrl &filePath, QString editorText);
    QString spacesBetweenTexts(QString firstText, QString secondText, QFont font, int rectWidth);
    void allowUndoAfterReplace(QQuickTextDocument *qDoc);

private:
    QTextCursor *m_TextCursor;
};

#endif // TEXTFILEOPERATIONS_H
